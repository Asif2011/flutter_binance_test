import 'dart:async';
import 'dart:convert';
import '../utils/computation.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_binance_test/models/candle.dart';
import 'package:flutter_binance_test/utils/computation.dart';
import 'package:http/http.dart' as http;








class RSI extends StatefulWidget {
  const RSI({Key? key}) : super(key: key);

  @override
  _RSIState createState() => _RSIState();
}

class _RSIState extends State<RSI> {
  late Future<List<Candle>> candles;
  int period = 14;
  String interval = "1d";
  bool runningState = true;
  bool stopSignal = false;
  String dropdownValue = "1d";
  late Future<List<dynamic>> allSymbolsPrice;
  List<String> allSymbols = [];
  Stream<List<Map<String, dynamic>>>? listRSI;
  late StreamController<List<Map<String, dynamic>>> myController;
  bool _visibleTextField = false;
  String searchKeywords = '';

  @override
  void initState() {
    makeRSIOrderedList();
    super.initState();
  }

  Future<void> refreshSymbols() async {
    // this.candles = getBinanceCandles(interval: "5m", symbol: "SLPBUSD");
    // this.allSymbolsPrice = getAllSymbolsPrice();
    // print("refreshSymbols() called");
    setState(() {});
  }

  Future<void> refreshRSIList() async {
    // this.listRSI = makeRSIOrderedList();
    // // print("refreshSymbols() called");
    print('refresh rsi values funcion called');
    // this.myController.close();
    if (runningState) {
      stopSignal = true;
    } else {
      stopSignal = false;
    }
    setState(() {
      makeRSIOrderedList();
      // this.myController = StreamController<List<Map<String, dynamic>>>();
    });
  }

  String removeDecimalZeroFormat(String s) {
    double num = double.parse(s);
    String formattedString = num
        .toString(); //convert simply string to double and then double to String will result into truncation of all decimal trailing zeros.

    return formattedString;
  }

  Future<void> makeRSIOrderedList() async {
    runningState = true;
    this.myController = StreamController<List<Map<String, dynamic>>>();
    List<Map<String, dynamic>> allSymbolsNames =
        extractAllSymbolsNames(await getAllSymbolsPrice());
    List<Map<String, dynamic>> listRSI = [];
    int chunkSymbolsCounter = 0;
    int totalSymbolsCounter = 0;
    if (allSymbolsNames.isNotEmpty) {
      for (Map element in allSymbolsNames) {
        print("$totalSymbolsCounter");
        chunkSymbolsCounter++;
        totalSymbolsCounter++;
        List<Candle> tempCandles = await getBinanceCandles(
            interval: interval, symbol: element['symbol']);
        double tempRSI = calculateRSI(tempCandles, this.period);
        listRSI.add({
          "symbol": element['symbol'],
          "price": removeDecimalZeroFormat(element['price']),
          "rsi": tempRSI,
          "open_time": tempCandles[0].date,
        });
        if (!stopSignal) {
          if (chunkSymbolsCounter == 10) {
            print("$totalSymbolsCounter symbols delivered");
            chunkSymbolsCounter = 0;
            listRSI.sortBy(["rsi"]);
            this.myController.add(listRSI);
            // this.myController.
          } else if (totalSymbolsCounter == allSymbolsNames.length) {
            print("RSI values of total $totalSymbolsCounter symbols delivered");
            listRSI.sortBy(["rsi"]);
            runningState = false;
            // controller.add(listRSI);
            this.myController.add(listRSI);
          }
        } else {
          print("Stream Closed");
          myController.addError(Error());
          stopSignal = false;
          // runningState = false;
          break;
        }
      }
    }

    // yield listRSI;
  }

  Future<List<Candle>> getBinanceCandles(
      {String interval: "1d", String symbol: "BTCBUSD"}) async {
    //fetch k-line data last 50 to current candle using binance spot api
    // String symbol = "BTCBUSD";
    String interval = this.interval;
    final uri = Uri.parse("https://api.binance.com/api/v3/klines?" +
        "symbol=$symbol&" +
        "interval=$interval&limit=50");

    final res = await http.get(
      uri,
    );
    List<Candle> candles = (jsonDecode(res.body) as List<dynamic>)
        .map((e) => Candle.fromJson(e))
        .toList()
        .reversed
        .toList();
    this.interval = interval;
    return candles;
  }

  Future<List<dynamic>> getAllSymbolsPrice() async {
    List<dynamic> allSymbolsData = [];
    final uriAllSylmbols =
        Uri.parse("https://api.binance.com/api/v3/ticker/price");
    final http.Response res = await http.get(uriAllSylmbols);
    try {
      allSymbolsData = (jsonDecode(res.body.toString()) as List<dynamic>);
      // allSymbolsData.forEach((element) {
      //   // allSymbols.add(element["symbol"]);
      //   var temp = filterSymbols(element["symbol"], quoteSymbols: [
      //     "BUSD",
      //   ]);
      //   if (temp != null) {
      //     allSymbols.add(temp["filteredSymbol"]!);
      //   }
      // });
    } catch (e) {
      // TODO
      print("error occurred:\n$e");
    }

    return allSymbolsData;
  }

  List<Map<String, dynamic>> extractAllSymbolsNames(
      List<dynamic> listallSymbolsPrice) {
    List<Map<String, dynamic>> allSymbols = [];
    listallSymbolsPrice.forEach((element) {
      // allSymbols.add(element["symbol"]);
      var temp = filterSymbols(element["symbol"], quoteSymbols: [
        "BUSD",
      ]);
      if (temp != null) {
        // allSymbols.add(temp["filteredSymbol"]!);
        allSymbols.add(element);
      }
    });
    return allSymbols;
  }
  
  

  double calculateRSI(List<Candle> candles, int period) {
    candles = candles.reversed.toList();
    double rsi = 0;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;
    // print("close price is:\n");
    for (int i = 0; i < candles.length; i++) {
      // print('candles are ${candles.length}');
      Candle candle = candles[i];
      final double closePrice = candle.close;
      // print("$closePrice");
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double maxR = max(0, closePrice - candles[i - 1].close.toDouble());
        double absR = (closePrice - candles[i - 1].close.toDouble()).abs();

        rsiMaxEma = (maxR + (period - 1) * rsiMaxEma) / period;
        rsiABSEma = (absR + (period - 1) * rsiABSEma) / period;
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }
      if (i < (period - 1)) rsi = 0;
      if (rsi != 0 && rsi.isNaN) rsi = 0;
      // entity.rsi = rsi;
    }
    return rsi;
  }

  @override
  Widget build(BuildContext context) {
    // rsi = calcRSI(candles);
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Scaffold(
          appBar: AppBar(
            title:Text("RSI Low to High"),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  semanticLabel: "Search",
                ),
                onPressed: () {
                  setState(() {
                    _visibleTextField = !_visibleTextField;
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Stack(
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          // TextField(),
                          DropdownButton<String>(
                            value: dropdownValue,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 6,
                            menuMaxHeight:
                                MediaQuery.of(context).size.height / 2,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                                interval = dropdownValue;
                                refreshRSIList();
                              });
                            },
                            items: <String>[
                              '1m',
                              '3m',
                              '5m',
                              '15m',
                              '30m',
                              '1h',
                              '2h',
                              '4h',
                              '6h',
                              '8h',
                              '12h',
                              '1d',
                              '3d',
                              '1w',
                              '1M'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: period.toString(),
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 6,
                            menuMaxHeight:
                                MediaQuery.of(context).size.height / 2,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                this.period = int.parse(newValue!);
                                // period = int.parse(dropdownValue);
                                refreshRSIList();
                              });
                            },
                            items: <String>[
                              '14',
                              '6',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  Visibility(
                    visible: _visibleTextField,
                    child: AnimatedOpacity(
                      // If the widget is visible, animate to 0.0 (invisible).
                      // If the widget is hidden, animate to 1.0 (fully visible).
                      opacity: _visibleTextField ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      // The green box must be a child of the AnimatedOpacity widget.
                      child: Container(
                        color: Theme.of(context).primaryColorLight,
                        child: TextField(
                          onChanged: (value) {
                            this.searchKeywords = value.toLowerCase();
                            setState(() {});
                          },
                          style: TextStyle(fontSize: 18,
                          color: Colors.black),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 20),
                            labelText: 'Search',
                            // suffixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              StreamBuilder(
                  // stream: this.listRSI,
                  stream: this.myController.stream,
                  builder: (context, symbolsSnapshot) {
                    Widget tempRSIWidget = Center(
                      child: CircularProgressIndicator(),
                    );
                    if (symbolsSnapshot.hasData) {
                      List<Map<String, dynamic>> tempRSIList =
                          symbolsSnapshot.data as List<Map<String, dynamic>>;

                      tempRSIWidget = Expanded(
                        // height: MediaQuery.of(context).size.height - 100,
                        // width: double.infinity,
                        child: RefreshIndicator(
                          displacement: 40,
                          onRefresh: refreshRSIList,
                          child: ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: tempRSIList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                //   print("Symbol = ${tempRSIList[index]["symbol"].toString().toLowerCase()} and search= $searchKeywords");
                                Widget tempListTile = tempRSIList[index]
                                            ["symbol"]
                                        .toString()
                                        .toLowerCase()
                                        .contains(this.searchKeywords)
                                    ? Card(
                                        elevation: 0.5,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(5),
                                          leading: Text(
                                              tempRSIList[index]["symbol"]),
                                          trailing: Text(
                                            tempRSIList[index]["rsi"]
                                                        .toString()
                                                        .length <=
                                                    5
                                                ? tempRSIList[index]["rsi"]
                                                    .toString()
                                                : tempRSIList[index]["rsi"]
                                                    .toString()
                                                    .substring(0, 5),
                                            style: TextStyle(
                                                backgroundColor: Colors.indigo,
                                                color: Colors.white,
                                                fontSize: 20,
                                                decoration:
                                                    TextDecoration.overline),
                                          ),
                                          title: Text(tempRSIList[index]
                                                  ["price"]
                                              .toString()),
                                          subtitle: Text(tempRSIList[index]
                                                  ["open_time"]
                                              .toString()),

                                          // subtitle: Text("Raza") ,
                                        ),
                                      )
                                    : Container();
                                return tempListTile;
                              }),
                        ),
                      );
                    }
                    return tempRSIWidget;
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
