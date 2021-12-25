import 'dart:async';

void main() async{
var x = getInts();
late StreamSubscription<List<int>> z;
await Future.delayed(Duration(seconds: 5));
z = x.listen((event) {
  print(event);
  if (event.length == 4) {
    z.pause(Future.delayed(Duration(seconds: 5)));    
  }
});


// var x = timedCounter1(Duration(seconds: 1),5);
// x.listen((event) {print(event);});
// 



  ///////////////////////////////////////
  // var x = await timedCounter(Duration(seconds:2,),3);
  // x.listen((event) {print(event);});
  // listenAfterDelay();
  // listenWithPause();
  /////////////////////////////////////////
}



Stream<List<int>> getInts()async*{
  print('getInt() called');
  List<int> y=[];
  try {
      List<int> tempList = List.generate(10, (index) => index);
  for (var item in tempList) {
    await Future.delayed(Duration(seconds: 1));
    y.add(item);
    yield y;
  }
  } catch (e) {
    print(e);
  }
  finally{
    
    print("finally block called and y have values $y");
  }
}

// Stream<int> timedCounter1(Duration interval, [int? maxCount]) async* {
//   int i = 0;
//   while (true) {
//     await Future.delayed(interval);
//     yield i++;
//     if (i == maxCount) break;
//   }
// }







/////////////////////////////////////////
// creating streams code sample given below
// 
///////////////////////////////////////////////
Stream<int> timedCounter(Duration interval, [int? maxCount]) {
  late StreamController<int> controller;
  Timer? timer;
  int counter = 0;

  void tick(_) {
    counter++;
    controller.add(counter); // Ask stream to send counter values as event.
    if (counter == maxCount) {
      timer?.cancel();
      controller.close(); // Ask stream to shut down and tell listeners.
    }
  }

  void startTimer() {
    timer = Timer.periodic(interval, tick);
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  controller = StreamController<int>(
      onListen: startTimer,
      onPause: stopTimer,
      onResume: startTimer,
      onCancel: stopTimer);

  return controller.stream;
}



// Stream<int> timedCounter(Duration interval, [int? maxCount]) {
//   var controller = StreamController<int>();
//   int counter = 0;
//   void tick(Timer timer) {
//     counter++;
//     controller.add(counter); // Ask stream to send counter values as event.
//     if (maxCount != null && counter >= maxCount) {
//       timer.cancel();
//       controller.close(); // Ask stream to shut down and tell listeners.
//     }
//   }

//   Timer.periodic(interval, tick); // BAD: Starts before it has subscribers.
//   return controller.stream;
// }


void listenAfterDelay() async {
  var counterStream = timedCounter(const Duration(seconds: 1), 15);
  await Future.delayed(const Duration(seconds: 5));

  // After 5 seconds, add a listener.
  await for (int n in counterStream) {
    print(n); // Print an integer every second, 15 times.
  }
}

void listenWithPause() {
  var counterStream = timedCounter(const Duration(seconds: 1), 15);
  late StreamSubscription<int> subscription;

  subscription = counterStream.listen((int counter) {
    print(counter); // Print an integer every second.
    if (counter == 5) {
      // After 5 ticks, pause for five seconds, then resume.
      subscription.pause(Future.delayed(const Duration(seconds: 5)));
    }
  });
}

/////////////////////////////////////////////////////
// creating streams sample code ended
//
/////////////////////////////////////////////////////
