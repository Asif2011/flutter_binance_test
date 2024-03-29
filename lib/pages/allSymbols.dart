import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


extension SortBy on List {
  sortBy(List<String> keys) {
    this.sort((a, b) {
      for(int k=0; k<keys.length; k++) {
        String key = keys[k];
        int comparison = Comparable.compare((a[key]??""), (b[key]??""));
        if(comparison != 0){
          return comparison;
        }
      }
      return 0;
    });
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  WebSocketChannel? _channel;


  @override
  void dispose() {
    if (_channel != null) {
      print("Channel closed");
      _channel!.sink.close();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (_channel != null) _channel!.sink.close();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/ws'),
    );
    _channel!.sink.add(
      jsonEncode(
        {
          "method": "SUBSCRIBE",
          // "params": ["btcusdt@kline_" + "1m","adausdt@kline_" + "1m"],
          "params": ["!ticker@arr"],
          "id": 23
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            StreamBuilder(
                stream: _channel == null ? null : _channel!.stream,
                builder: (context, snapshot) {
                  Map y = {"name": "Asif"};
                  List temp = [];
                  Widget myWidget = CircularProgressIndicator();

                  // print(snapshot.data);
                  // final data = jsonDecode(snapshot.data as String) as Map<String, dynamic>;
                  try {
                    if (snapshot.data != null) {
                      // print(
                      //     "type of incoming data is ${snapshot.data.runtimeType}");
                      temp =
                          jsonDecode(snapshot.data as String) as List<dynamic>;
                      if (temp is List<dynamic>) {

                        // print(temp.toString());
                        // print(temp.length);
                        temp.sortBy(['c']);
                        // temp.reversed.toList(); //to reverse the list
                        myWidget = Expanded(
                         // height: MediaQuery.of(context).size.height - 100,
                          // width: double.infinity,
                          child: ListView.builder(
                            itemCount: temp.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              Widget myCardWidget = SizedBox.shrink();
                              String symbol = "${temp[index]['s']}";
                              RegExp exp = RegExp(
                                  r"^(\w+)(BTC|ETH|BNB|USDT|PAX|TUSD|USDC|XRP|BUSD|USDS)$");
                              Iterable<RegExpMatch> matches =
                                  exp.allMatches(symbol);

                              if (matches.isNotEmpty) {
                                // print(matches.elementAt(0).group(1));
                                String baseSymbol =
                                    matches.elementAt(0).group(1)!;
                                String quoteSymbol =
                                    matches.elementAt(0).group(2)!;
                                if (quoteSymbol == "BTC" ||
                                    quoteSymbol == "ETH" ||
                                    quoteSymbol == "BNB" ||
                                    quoteSymbol == "PAX" ||
                                    quoteSymbol == "XRP") {
                                } else {
                                  myCardWidget = Card(
                                    margin: EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "$baseSymbol/$quoteSymbol",
                                                textScaleFactor: 1.3,
                                              ),
                                              Text("${temp[index]['c']}"),
                                            ]),
                                        Text("Time:${DateTime.fromMillisecondsSinceEpoch(temp[index]['E']).hour}:" +
                                            "${DateTime.fromMillisecondsSinceEpoch(temp[index]['E']).minute}"),
                                      ],
                                    ),
                                  );
                                }
                              }
                              return myCardWidget; // print(symbolLength);
                            },
                          ),
                        );
                        // y = data;
                        // myWidget = SingleChildScrollView(
                        //     // child: Text(snapshot.data.toString(),maxLines: 5, softWrap: true,));
                        //     child: Text(
                        //         "Time:${DateTime.fromMillisecondsSinceEpoch(temp[0]['E']).hour}:" +
                        //             "${DateTime.fromMillisecondsSinceEpoch(temp[0]['E']).minute}\n"
                        //                 "Symbol:${temp[0]['s']}\n" +
                        //             "Pric:${temp[0]['c']}"));
                      }
                    }
                  } catch (e) {
                    print("incoming data mismatch,little wait.....");
                  }

                  return myWidget;
                })
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
