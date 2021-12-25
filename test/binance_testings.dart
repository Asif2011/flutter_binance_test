import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';


Future<void> main() async {
  // testSHAFunction();
  // testHMAC_SHA256Function();
  testUrlRequest();
}



String testHMAC_SHA256FunctionBinance(String message, String Secretkey ) {
  
  var key = utf8.encode(Secretkey);
  var bytes = utf8.encode(message);

  var hmacSha256Signature = Hmac(sha256, key); // HMAC-SHA256
  var digest = hmacSha256Signature.convert(bytes);

  print("HMAC digest as bytes: ${digest.bytes}");
  print("HMAC digest as hex string: $digest");
  return digest.toString();
}

void testSHAFunction() {
  var bytes = utf8.encode('woolhadotcom');
  Digest sha256Result = sha256.convert(bytes);
  print('SHA256: $sha256Result');
}

Future<void> testUrlRequest() async {

  Map<String, dynamic> fetchQueryMap = {
    'symbol': "BNBBUSD",
    "interval": "1d",
    "limit": "50"
  };

  String apiKey = 'IOiLRaHqodizvJKaFkvawLpd7jTVKTMzaHAY8AnixFshxcH6kEiPVB3jLw9oqBpW';
  String secKey = '4Ulyt7c147QcoHWoRAceeSRgfRP4tIe5OzEPaoKdgBy1Rr031s2trO6dKnXhJc0y';
  var timeStamp = DateTime.now().millisecondsSinceEpoch;
  String queryString = 'symbol=BNBBUSD&side=BUY&type=LIMIT&timeInForce=GTC&quantity=0.026&price=560&recvWindow=10000&timestamp=$timeStamp';
  String signatureBinance = testHMAC_SHA256FunctionBinance(queryString, secKey);
  Uri url = Uri(
    scheme: "https",
    host:  "api.binance.com",
    path:  "/api/v3/order",
    query: queryString+"&signature=$signatureBinance",
    // queryParameters: fetchQueryMap,
  );

  print(url.toString());
  var httpClient = HttpClient();
  var request = await httpClient.postUrl(url);
  // getUrl(url);
  request.headers.set("X-MBX-APIKEY", apiKey , preserveHeaderCase: true);
  var response = await request.close();
  var data = await utf8.decoder.bind(response).toList();
  print('Response ${response.statusCode}: $data');
  httpClient.close();
}






// import "dart:html";
// // import 'dart:convert';
// // import "dart:io";
// // import 'dart:core';

// void main(List<String> args) {
//   Map<String,dynamic> data = {"symbol":"BNBBUSD"};
//   Uri myUri = Uri.parse('https://api.binance.com/api/v3/klines',);
//   myUri.replace(queryParameters: data);
  
//   final request = new HttpRequest();
//    request
//    ..open("GET", Uri.encodeFull(myUri.toString()),async: true,)
   
//    ..send(data);
   
   


//   //   HttpRequest.request(
//   //   'https://api.binance.com/api/v3/klines',
//   //   method: 'GET',
//   //   responseType: "json",
//   //   sendData: json.encode(data),
//   //   requestHeaders: {
//   //     'Content-Type': 'application/json; charset=UTF-8'
//   //   },
//   //   onProgress: (progress){ print(progress.loaded);},
//   // )
//   // .then((resp) {
//   //   print(resp.responseUrl);
//   //   print(resp.responseText);           
//   // });



// //   HttpClient client = new HttpClient();
// // client.getUrl(Uri.parse("https://api.binance.com/api/v3/klines?"))
// // .then((HttpClientRequest request) {
// //       request.headers.contentType
// //     = new ContentType("application", 'text/json', charset: "UTF-8");
// //     request.headers.add(HttpHeaders.contentTypeHeader, "text/plain");
// //     request.headers.set("symbol", "BNBBUSD");
// //     // Map<String,String> body = {"symbol": "BNBBUSD","interval":"1d","limit":"50"};
// //     // request.headers.contentLength =
// //     //     42;
// //     // request.write(body);
// //     // request.headers.add("symbol", "bnbbusd");
// //     // request.headers.add("interval", "1d");
// //     // request.headers.add("limit", "50");
// //     return request.close();
// //     }
// //     ).then((HttpClientResponse response) {
// //       // Process the response.
// //       response.transform(Utf8Decoder()).listen(print);
// //     });
  
// }