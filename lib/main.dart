import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
          "id": 1
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
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            StreamBuilder(
                stream: _channel == null ? null : _channel!.stream,
                builder: (context, snapshot) {
                  Map y = {"name": "Asif"};
                  List temp = [];

                  if (snapshot.data != null) {
                    // final data = jsonDecode(snapshot.data as String) as Map<String, dynamic>;
                    final temp =  jsonDecode(snapshot.data as String) as List<dynamic>;
                    
                    // for (var x in data) {
                    //   print(x);
                    // }
                    // print("Time: $data[E]\n$data[s] price:$data[]");
                    // temp = snapshot.data as  List<Map>;

                    print(temp.length);
                    // y = data;
                    return SingleChildScrollView(
                      // child: Text(snapshot.data.toString(),maxLines: 5, softWrap: true,));
                      child: Text(
                        "Time:${DateTime.fromMillisecondsSinceEpoch(temp[0]['E'])}\n" +
                        "Symbol:${temp[0]['s']}\n" +
                        "Pric:${temp[0]['c']}"
                      ));
                  }
                  else if (snapshot.hasError) {
                    return CircularProgressIndicator();
                  }
                  else 
                  return SingleChildScrollView(
                      child: CircularProgressIndicator());
                
                  })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
