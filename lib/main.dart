

import 'package:flutter/material.dart';
import 'package:flutter_binance_test/pages/RSIPage.dart';
import 'package:flutter_binance_test/pages/allSymbols.dart';
import 'package:flutter_binance_test/routes.dart';



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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binance Indicators Observer',
      themeMode:ThemeMode.light,
      debugShowCheckedModeBanner: false,
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
        
        primarySwatch: Colors.indigo,
        
      ),
      initialRoute:AppRoutes.RSIRoute,
      routes:{
        AppRoutes.PricesRoute:(context){return MyHomePage(title: "Flutter Binance RSI");},
         AppRoutes.RSIRoute:(context){return RSI();}
        // MyRoutes.loginRoute:(context){return LoginScreen();},
        // MyRoutes.homeRoute: (context){return HomeScreen();},
        // MyRoutes.catalogRoute:(context){return CatalogScreen();}
      },
      home: MyHomePage(title: 'RSI'),
    );
  }
}



