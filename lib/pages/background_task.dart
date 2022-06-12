import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as web_status;

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  int tempUpdateCount = 0;
  int totalUpdateCount = 0;
  Duration connectionDuration = Duration.zero;
  DateTime startTime = DateTime.now().toLocal();
  late DateTime endTime;

  Future<void> connectBinanceSocket() async {
    try {
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

      ///1
      // var logFile = File('log.txt');
      // var sink = logFile.openWrite();
      ///1
      channel2.stream.listen(
        (message) {
          // print("message is: $message");

          if (message != null) {
            var temp;
            // try {
            temp = jsonDecode(message as String) as List<dynamic>;

            // print("value is:${temp.toString()}");
            // } catch (e) {
            //   print("error on decoding due to: $e");
            // }
            if (temp is List<dynamic>) {
              // print(temp.toString());
              // print(temp.length);
              print("response message is List");

              ///1
              // sink.write('${temp.toString()}\n\n\n');
              ///1
              ///
              // temp.sortBy(['c']);
              //// new lines for test
              tempUpdateCount++;

              if (tempUpdateCount == 10) {
                FlutterForegroundTask.updateService(
                  notificationTitle: "Binance Price Updates",
                  notificationText: DateTime.now().toLocal().toString(),
                );
                tempUpdateCount = 0;
                totalUpdateCount += 10;
              }

              ///
              ///
            } else if (temp is Map<String, dynamic>) {
              print("response message is Map");
            }
          } else
            print("Binance Socket message is invalid");
        },
        onError: (Object error, StackTrace) async {
          print("Error is:{${error.toString()}}error occurred");
          endTime = DateTime.now().toLocal();
          connectionDuration = endTime.difference(startTime);
          FlutterForegroundTask.updateService(
            notificationTitle: "Binance Disconnected",
            notificationText:
                "total ${totalUpdateCount + tempUpdateCount} updates received till ${endTime.toString()} and connection remain for ${connectionDuration.inMinutes.toString()} mins",
          );
          channel2?.sink.close(web_status.goingAway);

          ///1
          // await sink.flush();
          // await sink.close();

          ///1
        },
        onDone: () async {
          print("Task done");
          endTime = DateTime.now().toLocal();

          ///1
          // sink.write('Done on $endTime');
          // await sink.flush();
          // await sink.close();
          ///1
          connectionDuration = endTime.difference(startTime);
          FlutterForegroundTask.updateService(
            notificationTitle:
                "${totalUpdateCount + tempUpdateCount} Binance Updates Done",
            notificationText:
                "Task Done with run for ${connectionDuration.inMinutes.toString()} mins",
          );
          channel2?.sink.close(web_status.goingAway);
        },
        cancelOnError: false,
      );
    } on Exception catch (e) {
      // TODO
      FlutterForegroundTask.updateService(
        notificationTitle: "Binance Price Updates",
        notificationText: "waiting" + DateTime.now().toLocal().toString(),
      );
    }
  }
//onStart function remains in RAM when service is running
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
    connectBinanceSocket();

  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // FlutterForegroundTask.updateService(
    //     notificationTitle: 'FirstTaskHandler',
    //     notificationText: timestamp.toString(),
    //     callback: updateCount >= 10 ? updateCallback : null);

    // // Send data to the main isolate.
    // sendPort?.send(timestamp);
    // sendPort?.send(updateCount);

    // updateCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    //2
    FlutterForegroundTask.updateService(
      notificationTitle: "Binance Price Updates",
      notificationText: "onDestroy called",
    );

    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }
}

void updateCallback() {
  FlutterForegroundTask.setTaskHandler(SecondTaskHandler());
}

class SecondTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
        notificationTitle: 'SecondTaskHandler',
        notificationText: timestamp.toString());

    // Send data to the main isolate.
    sendPort?.send(timestamp);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}

class BackgroundServiceTest extends StatefulWidget {
  const BackgroundServiceTest({Key? key}) : super(key: key);

  @override
  _BackgroundServiceTestState createState() => _BackgroundServiceTestState();
}

class _BackgroundServiceTestState extends State<BackgroundServiceTest> {
  ReceivePort? _receivePort;

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          // name: "simple_notification"
        ),
        playSound: true,
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
  }

  @override
  void dispose() {
    _receivePort?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Background Service"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: startForegroundTask, child: Text("Start")),
            ElevatedButton(onPressed: stopForegroundTask, child: Text("Stop")),
          ],
        ),
      ),
    );
  }

  Future<bool> startForegroundTask() async {
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is DateTime) {
          print('receive timestamp: $message');
        } else if (message is int) {
          print('receive updateCount: $message');
        }
      });
      return true;
    }
    return false;
  }

  Future<bool> stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }
}
