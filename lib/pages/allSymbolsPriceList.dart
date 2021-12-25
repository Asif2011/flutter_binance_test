import 'dart:convert';
import '../utils/computation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as web_status;
// import 'package:flutter/services.dart';
// import 'package:background_fetch/background_fetch.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;
//   if (isTimeout) {
//     // This task has exceeded its allowed running-time.
//     // You must stop what you're doing and immediately .finish(taskId)
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }
//   print('[BackgroundFetch] Headless event received: $taskId"');
//   //--// Do your work here...
//   var timestamp = DateTime.now();

//   var prefs = await SharedPreferences.getInstance();

//   // Read fetch_events from SharedPreferences
//   var events = <String>[];
//   var json = prefs.getString(EVENTS_KEY);
//   if (json != null) {
//     events = jsonDecode(json).cast<String>();
//   }
//   // Add new event.
//   events.insert(0, "$taskId@$timestamp [Headless]");
//   // Persist fetch events in SharedPreferences
//   prefs.setString(EVENTS_KEY, jsonEncode(events));

//   if (taskId == 'flutter_background_fetch') {
//     //DISABLED:  uncomment to fire a scheduleTask in headlessTask.
//     // BackgroundFetch.scheduleTask(TaskConfig(
//     //     taskId: "com.transistorsoft.customtask",
//     //     delay: 5000,
//     //     periodic: false,
//     //     forceAlarmManager: false,
//     //     stopOnTerminate: false,
//     //     enableHeadless: true));
//   }

//   BackgroundFetch.finish(taskId);
// }

Future<void> connectBinanceSocket() async {
  WebSocketChannel? channel2;
  if (channel2 != null) channel2.sink.close();
  channel2 = WebSocketChannel.connect(
    Uri.parse('wss://stream.binance.com:9443/ws'),
  );
  channel2.sink.add(
    jsonEncode(
      {
        "method": "SUBSCRIBE",
        // "params": ["btcusdt@kline_" + "1m","adausdt@kline_" + "1m"],
        "params": ["!ticker@arr"],
        "id": 24,
      },
    ),
  );
  channel2.stream.listen(
    (message) {
      // print("message is: $message");
      if (message != null) {
        var temp;
        try {
          temp = jsonDecode(message as String) as List<dynamic>;
          // print("value is:${temp.toString()}");
        } catch (e) {
          print("error on decoding due to: $e");
        }
        if (temp is List<dynamic>) {
          // print(temp.toString());
          // print(temp.length);
          print("response message is List");
          temp.sortBy(['c']);
        } else if (temp is Map<String, dynamic>) {
          print("response message is Map");
        }
      } else
        print("Binance Socket message is invalid");
    },
    onError: (Object error, StackTrace) {
      print("Error is:{${error.toString()} }error occurred");
    },
    onDone: () {
      print("Task done");
      channel2?.sink.close(web_status.goingAway);
    },
    cancelOnError: true,
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebSocketChannel? _channel;
  //////
  bool _enabled = true;
  int _status = 0;

  var _visibleTextField = false;

  String searchKeywords ='';

  @override
  void initState() {
    // TODO: implement initState
    // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    // initPlatformState();
    super.initState();
  }

  // Future<void> initPlatformState() async {
  //   // var prefs = await SharedPreferences.getInstance();
  //   // var json = prefs.getString(EVENTS_KEY);
  //   if (json != null) {
  //     setState(() {
  //       _events = jsonDecode(json).cast<String>();
  //     });
  //   }
// Configure BackgroundFetch.
  // try {
  //   var status = await BackgroundFetch.configure(
  //       BackgroundFetchConfig(
  //         minimumFetchInterval: 15,
  //         /*
  //     forceAlarmManager: false,
  //     stopOnTerminate: false,
  //     startOnBoot: true,
  //     enableHeadless: true,
  //     requiresBatteryNotLow: false,
  //     requiresCharging: false,
  //     requiresStorageNotLow: false,
  //     requiresDeviceIdle: false,
  //     requiredNetworkType: NetworkType.NONE,

  //      */
  //       ),
  //       _onBackgroundFetch,
  //       _onBackgroundFetchTimeout);
  //   print('[BackgroundFetch] configure success: $status');
  //   setState(() {
  //     _status = status;
  //   });

  // Schedule a "one-shot" custom-task in 10000ms.
  // These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
  // where device must be powered (and delay will be throttled by the OS).
  //   BackgroundFetch.scheduleTask(TaskConfig(
  //       taskId: "com.transistorsoft.customtask",
  //       delay: 10000,
  //       periodic: false,
  //       forceAlarmManager: true,
  //       stopOnTerminate: false,
  //       enableHeadless: true));
  // } on Exception catch (e) {
  //   print("[BackgroundFetch] configure ERROR: $e");
  // }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  //   if (!mounted) return;
  // }

  // void _onBackgroundFetch(String taskId) async {
  //   var prefs = await SharedPreferences.getInstance();
  //   var timestamp = DateTime.now();
  //   // This is the fetch-event callback.
  //   print("[BackgroundFetch] Event received: $taskId");
  //   setState(() {
  //     _events.insert(0, "$taskId@${timestamp.toString()}");
  //   });
  //   // Persist fetch events in SharedPreferences
  //   prefs.setString(EVENTS_KEY, jsonEncode(_events));

  //   if (taskId == "flutter_background_fetch") {
  //     // Schedule a one-shot task when fetch event received (for testing).
  //     /*
  //     BackgroundFetch.scheduleTask(TaskConfig(
  //         taskId: "com.transistorsoft.customtask",
  //         delay: 5000,
  //         periodic: false,
  //         forceAlarmManager: true,
  //         stopOnTerminate: false,
  //         enableHeadless: true,
  //         requiresNetworkConnectivity: true,
  //         requiresCharging: true
  //     ));
  //      */
  //   }
  //   // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
  //   // for taking too long in the background.
  //   BackgroundFetch.finish(taskId);
  // }

  // void _onBackgroundFetchTimeout(String taskId) {
  //   print("[BackgroundFetch] TIMEOUT: $taskId");
  //   BackgroundFetch.finish(taskId);
  // }

  // void _onClickEnable(enabled) {
  //   setState(() {
  //     _enabled = enabled;
  //   });
  //   if (enabled) {
  //     BackgroundFetch.start().then((status) {
  //       print('[BackgroundFetch] start success: $status');
  //     }).catchError((e) {
  //       print('[BackgroundFetch] start FAILURE: $e');
  //     });
  //   } else {
  //     BackgroundFetch.stop().then((status) {
  //       print('[BackgroundFetch] stop success: $status');
  //     });
  //   }
  // }

  // void _onClickStatus() async {
  //   var status = await BackgroundFetch.status;
  //   print('[BackgroundFetch] status: $status');
  //   setState(() {
  //     _status = status;
  //   });
  // }

  // void _onClickClear() async {
  //   var prefs = await SharedPreferences.getInstance();
  //   prefs.remove(EVENTS_KEY);
  //   setState(() {
  //     _events = [];
  //   });
  // }

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
        title: _visibleTextField? Visibility(
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
                  ):Text(widget.title),
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
        ]
        // systemOverlayStyle: SystemUiOverlayStyle.light,
        // brightness: Brightness.light,
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
                                  myCardWidget =temp[index]['s'].toString().toLowerCase().contains(this.searchKeywords)? Card(
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
                                  ):SizedBox.shrink();
                                }
                              }
                              return myCardWidget; // print(symbolLength);
                            },
                          ),
                        );
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
    );
  }

  @override
  void dispose() {
    if (_channel != null) {
      print("Channel closed");
      _channel!.sink.close();
    }
    super.dispose();
  }
}
