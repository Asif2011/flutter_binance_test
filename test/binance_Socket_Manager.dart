// import 'package:web_socket_support/web_socket_support.dart';

// Future<void>? main(List<String> args) {
//   connectBinance();  
// }




// // WebSocketConnection will be obtained via _onWsOpen callback in WebSocketClient








// Future<void> connectBinance()async{

// WebSocketConnection? _webSocketConnection;

// // instantiate WebSocketClient with DefaultWebSocketListener and some callbacks
// // Of course you can use you own WebSocketListener implementation
// final WebSocketClient _wsClient = WebSocketClient(DefaultWebSocketListener.forTextMessages(
//         (wsc) => _webSocketConnection = wsc,                       // _onWsOpen callback
//         (code, msg) => print('Connection closed. Resaon: $msg'),  // _onWsClosed callback
//         (msg) => print('Message received: $msg')));               // _onStringMessage callback
// // ...
// // connect to remote ws endpoint
// await _wsClient.connect("wss://stream.binance.com:9443/ws/bnbbusd@ticker",);


// // ...
// // After connection is established, use obtained WebSocketConnection instance to send messages
// // _webSocketConnection?.sendStringMessage('Hello from Websocket support');
// }