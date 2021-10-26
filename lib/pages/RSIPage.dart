import 'dart:async';
import 'dart:convert';
// import 'dart:developer';
import '../utils/computation.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_binance_test/models/candle.dart';
import 'package:flutter_binance_test/utils/computation.dart';
// import 'package:flutter_binance_test/utils/rsi_smma.dart';
import 'package:http/http.dart' as http;

class RSI extends StatefulWidget {
  const RSI({Key? key}) : super(key: key);

  @override
  _RSIState createState() => _RSIState();
}

class _RSIState extends State<RSI> {
  // late List<String> allSymbols;
  late Future<List<Candle>> candles;
  int period = 14;
  String interval = "5m";

  late Future<List<dynamic>> allSymbolsPrice;
  List<String> allSymbols = [];
  Stream<List<Map<String, dynamic>>>? listRSI;
  late StreamController<List<Map<String, dynamic>>> myController;

  @override
  void initState() {
    super.initState();
    // this.candles = getBinanceCandles(
    //     interval: interval,
    //     symbol:
    //         "SLPBUSD"); // connecting with api and stream to get the  recent api candles of 1 frame
    this.listRSI = makeRSIOrderedList();
    

    // this.allSymbolsPrice = getAllSymbolsPrice().then((value) {makeRSIOrderedList(this.allSymbols); return value;});
    // ;
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
    setState(() {});
  }

  Stream<List<Map<String, dynamic>>> makeRSIOrderedList() async* {
    List<String> allSymbolsNames =
        extractAllSymbolsNames(await getAllSymbolsPrice());
    List<Map<String, dynamic>> listRSI = [];
    int shortCounter = 0;
    int totalCounter = 0;
    StreamController<List<Map<String, dynamic>>> controller =
        StreamController();
    if (allSymbolsNames.isNotEmpty) {
      for (String element in allSymbolsNames) {
        shortCounter++;
        totalCounter++;
        await Future.delayed(Duration(milliseconds: 90));
        List<Candle> tempCandles =
            await getBinanceCandles(interval: interval, symbol: element);
        double tempRSI = calculateRSI(tempCandles, this.period);
        listRSI.add({"symbol": element, "rsi": tempRSI});
        if (shortCounter == 10) {
          print("chunk delivered");
          shortCounter = 0;
          listRSI.sortBy(["rsi"]);
          yield listRSI;
        } else if (totalCounter == allSymbolsNames.length) {
          print("RSI values of total $totalCounter symbols delivered");
          listRSI.sortBy(["rsi"]); 
          yield listRSI;
        }
      }
    }    
  }

  // Stream<List<Map<String, dynamic>>> makeRSIOrderedList() async* {
  //   List<String> allSymbolsNames =
  //       extractAllSymbolsNames(await getAllSymbolsPrice());
  //   List<Map<String, dynamic>> listRSI = [];
  //   int shortCounter = 0;
  //   int totalCounter = 0;
  //   StreamController<List<Map<String, dynamic>>> controller =
  //       StreamController<List<Map<String, dynamic>>>();
  //   if (allSymbolsNames.isNotEmpty) {
  //     for (String element in allSymbolsNames) {
  //       shortCounter++;
  //       totalCounter++;
  //       await Future.delayed(Duration(milliseconds: 90));
  //       List<Candle> tempCandles =
  //           await getBinanceCandles(interval: interval, symbol: element);
  //       double tempRSI = calculateRSI(tempCandles, this.period);
  //       listRSI.add({"symbol": element, "rsi": tempRSI});
  //       if (shortCounter == 10) {
  //         print("chunk delivered");
  //         shortCounter = 0;
  //         listRSI.sortBy(["rsi"]);
  //         // controller.add(listRSI);
  //       } else if (totalCounter == allSymbolsNames.length) {
  //         print("RSI values of total $totalCounter symbols delivered");
  //         listRSI.sortBy(["rsi"]);
  //         // controller.add(listRSI);
  //         controller.add(listRSI);
  //       }
  //     }
  //   }
  // return controller.stream;
  //   // yield listRSI;
  // }

  Future<List<Candle>> getBinanceCandles(
      {String interval: "5m", String symbol: "BTCBUSD"}) async {
    //fetch k-line data last 500 to current candle using binance spot api
    // String symbol = "BTCBUSD";
    String interval = this.interval;
    // Map<String, String> params = {
    //   "method": "SUBSCRIBE",
    // };
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
    // List<Map<String,dynamic>> allSymbolsMap=[];
    List<dynamic> allSymbolsData = [];
    final uriAllSylmbols =
        Uri.parse("https://api.binance.com/api/v3/ticker/price");
    final http.Response res = await http.get(uriAllSylmbols);
    // print(res.body.runtimeType);
    try {
      allSymbolsData = (jsonDecode(res.body.toString()) as List<dynamic>);
      List<String> allSymbols = [];
      allSymbolsData.forEach((element) {
        // allSymbols.add(element["symbol"]);
        var temp = filterSymbols(element["symbol"], quoteSymbols: [
          "BUSD",
        ]);
        if (temp != null) {
          allSymbols.add(temp["filteredSymbol"]!);
        }
      });
    } catch (e) {
      // TODO
      print("error occurred:\n$e");
    }

    return allSymbolsData;
  }

  List<String> extractAllSymbolsNames(List<dynamic> listallSymbolsPrice) {
    List<String> allSymbols = [];
    listallSymbolsPrice.forEach((element) {
      // allSymbols.add(element["symbol"]);
      var temp = filterSymbols(element["symbol"], quoteSymbols: [
        "BUSD",
      ]);
      if (temp != null) {
        allSymbols.add(temp["filteredSymbol"]!);
      }
    });
    return allSymbols;
  }

  //   fetchCandles(symbol: "BTCBUSD", interval: interval).then(
  //     (value) => setState(
  //       () {
  //         this.interval = interval;
  //         candles = value;
  //       },
  //     ),
  //   );
  // }

  // Future<List<Candle>> fetchCandles(
  //     {required String symbol, required String interval}) async {
  //   final uri = Uri.parse(
  //       "https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=40");
  //   final res = await http.get(uri);
  //   return (jsonDecode(res.body) as List<dynamic>)
  //       .map((e) => Candle.fromJson(e))
  //       .toList()
  //       .reversed
  //       .toList();
  // }

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: refreshSymbols,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh_outlined),
      ),
      appBar: AppBar(
        title: Text("RSI Low to High"),
      ),
      //for fetching all cadles data from binance
      body: Column(
        children: [
          //

          // FutureBuilder(
          //   future: allSymbolsPrice,
          //   builder: (context, symbolsSnapshot) {
          //     Widget tempSymbolsWidget = CircularProgressIndicator();
          //     if (symbolsSnapshot.hasData) {
          //       // print("symbols are\n${symbolsSnapshot.data.toString()}");
          //       List<dynamic> temp = symbolsSnapshot.data as List<dynamic>;
          //       // jsonDecode(symbolsSnapshot.data as String) as List<dynamic>;
          //       // print("symbols are\n${temp.toString()}");
          //       if (temp is List<dynamic>) {
          //         tempSymbolsWidget = Expanded(
          //           // height: MediaQuery.of(context).size.height - 100,
          //           // width: double.infinity,
          //           child: RefreshIndicator(
          //             displacement: 20,
          //             onRefresh: refreshSymbols,
          //             child: ListView.builder(
          //                 physics: AlwaysScrollableScrollPhysics(),
          //                 itemCount: temp.length,
          //                 shrinkWrap: true,
          //                 itemBuilder: (context, index) {
          //                   Widget tempListTile = Card(
          //                     elevation: 0.5,
          //                     child: ListTile(
          //                       contentPadding: EdgeInsets.all(5),
          //                       leading: Text(temp[index]["symbol"]),
          //                       trailing: Text(temp[index]["price"]),
          //                     ),
          //                   );
          //                   return tempListTile;
          //                 }),
          //           ),
          //         );
          //       }

          //       // double RSI = calcRSI(snapshot.data as List<Candle>, this.period);
          //       // List<double> RSI = calculateRSIValues(snapshot.data as List<Candle>, 14);
          //       // tempWidget = Text(RSI.toString());
          //       // tempWidget = Text(getAllSymbols().toString());
          //       // setState(() {

          //       // });
          //     }
          //     return tempSymbolsWidget;
          //   },
          // ),
          StreamBuilder(
              stream: this.listRSI,
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
                      displacement: 20,
                      onRefresh: refreshRSIList,
                      child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: tempRSIList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Widget tempListTile = Card(
                              elevation: 0.5,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(5),
                                leading: Text(tempRSIList[index]["symbol"]),
                                trailing: Text(
                                  tempRSIList[index]["rsi"].toString().length <=
                                          5
                                      ? tempRSIList[index]["rsi"].toString()
                                      : tempRSIList[index]["rsi"]
                                          .toString()
                                          .substring(0, 5),
                                  style: TextStyle(
                                    backgroundColor: Colors.indigo,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                            return tempListTile;
                          }),
                    ),
                  );
                }
                return tempRSIWidget;
              }),
        ],
      ),
    );
  }
}
