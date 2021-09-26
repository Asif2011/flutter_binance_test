import 'dart:convert';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_binance_test/models/candle.dart';
import 'package:flutter_binance_test/utils/rsi_smma.dart';
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
  late double rsi;
  late Future<List<dynamic>> allSymbols;

  @override
  void initState() {
    this.candles = binanceFetch(
        interval); // connecting with api and stream to get the  recent api candles of 1 frame
    this.allSymbols = getAllSymbols();
    super.initState();
  }

  Future<List<Candle>> binanceFetch(String interval) async {
    //fetch k-line data last 500 to current candle using binance spot api
    String symbol = "BTCBUSD";
    String interval = this.interval;
    final uri = Uri.parse(
        "https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=50");
    final res = await http.get(uri);
    List<Candle> candles = (jsonDecode(res.body) as List<dynamic>)
        .map((e) => Candle.fromJson(e))
        .toList()
        .reversed
        .toList();
    this.interval = interval;
    return candles;
  }

  Future<List<dynamic>> getAllSymbols() async {
    // List<Map<String,dynamic>> allSymbolsMap=[];
    List<dynamic> allSymbols = [];
    final uriAllSylmbols =
        Uri.parse("https://api.binance.com/api/v3/ticker/price");
    final http.Response res = await http.get(uriAllSylmbols);
    // print(res.body.runtimeType);
    try {
      allSymbols = (jsonDecode(res.body.toString()) as List<dynamic>);
      // Map<String,dynamic> allSymbols = (jsonDecode(res.body.toString()) as Map<String,dynamic>);
      // allSymbolsMap =  [allSymbols];
        //  .toList()
        //   .reversed
        //   .toList();
    }catch (e) {
      // TODO
      print("error occurred:\n$e");
    }
    // print(allSymbols);
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

  double calcRSI(List<Candle> candles, int period) {
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
        onPressed: (){setState(() {
        });},
        tooltip: 'Refresh',
        child: Icon(Icons.refresh_outlined),
      ),
      appBar: AppBar(
        title: Text("RSI Low to High"),
      ),
      //for fetching all cadles data from binance
      body: Column(
        children: [
          FutureBuilder(
            future: candles,
            //for fetching all symbols and prices
            builder: (context, candlesSnapshot) {
              double rsi = 0;
              Widget tempCandlesWidget = CircularProgressIndicator();
              if (candlesSnapshot.hasData) {
                rsi = calcRSI(candlesSnapshot.data as List<Candle>, this.period);
                tempCandlesWidget = Text(rsi.toString());
                // Text(getAllSymbols().toString());
                // setState(() {

                // });
              }
              return tempCandlesWidget;
              // return Text(rsi.toString());
            },
          ),

          FutureBuilder(
                  future: allSymbols,
                  builder: (context, symbolsSnapshot) {
                    Widget tempSymbolsWidget = CircularProgressIndicator();
                    if (symbolsSnapshot.hasData) {
                      // print("symbols are\n${symbolsSnapshot.data.toString()}");
                      List<dynamic> temp = symbolsSnapshot.data as List<dynamic>;
                          // jsonDecode(symbolsSnapshot.data as String) as List<dynamic>;
                          // print("symbols are\n${temp.toString()}");
                      if (temp is List<dynamic>) {
                        tempSymbolsWidget = Expanded(
                          // height: MediaQuery.of(context).size.height - 100,
                          // width: double.infinity,
                          child: ListView.builder(
                              
                              itemCount: temp.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                Widget tempListTile = 
                                Card(
                                  elevation: 0.5,
                                  child: 
                                    ListTile(
                                      contentPadding: EdgeInsets.all(5),
                                      leading: Text(temp[index]["symbol"]),
                                      trailing: Text(temp[index]["price"]),
                                    ),
                                );
                                return tempListTile;
                              }),
                        );
                      }

                      // double RSI = calcRSI(snapshot.data as List<Candle>, this.period);
                      // List<double> RSI = calculateRSIValues(snapshot.data as List<Candle>, 14);
                      // tempWidget = Text(RSI.toString());
                      // tempWidget = Text(getAllSymbols().toString());
                      // setState(() {

                      // });
                    }
                    return tempSymbolsWidget;
                  },
                ),

        ],
      ),
    );
  }
}
