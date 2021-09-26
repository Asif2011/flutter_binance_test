

// class Candle {
//   late double openTime;
//   late double open;
//   late double close;
//   double getClose() => this.close;
//   double getOpen() => this.open;
// }

import 'package:flutter_binance_test/models/candle.dart';


double calcSmmaUp(List<Candle> candles, double n, int i, double avgUt1){
        if(avgUt1==0){
            double sumUpChanges = 0;

            for(int j = 0; j < n; j++){
                double change = candles[i - j].close - candles[i - j].open;

                if(change > 0){
                    sumUpChanges+= change;
                }
            }
            return sumUpChanges / n;
        }else {
            double change = candles[i].close - candles[i].open;
            if(change < 0){
               change = 0;
            }
            return ((avgUt1 * (n-1)) + change) / n ;
        }
    }

double calcSmmaDown(List<Candle> candles, double n, int i, double avgDt1){
        if(avgDt1==0){
            double sumDownChanges = 0;

            for(int j = 0; j < n; j++){
                double change = candles[i - j].close - candles[i - j].open;

                if(change < 0){
                    sumDownChanges-= change;
                }
            }
            return sumDownChanges / n;
        }else {
            double change = candles[i].close - candles[i].open;
            if(change > 0){
                change = 0;
            }
            return ((avgDt1 * (n-1)) - change) / n ;
        }
    }

List<double> calculateRSIValues(List<Candle> candles, double n){

        List<double> results = [];

        double ut1 = 0;
        double dt1 = 0;
        for(int i = 0; i < candles.length; i++){
            if(i<(n)){
                continue;
            }
            ut1 = calcSmmaUp(candles, n, i, ut1);
            dt1 = calcSmmaDown(candles, n, i, dt1);

            results[i] = 100.0 - 100.0 / (1.0 +
                    calculateRS(ut1,
                                dt1));

        }

        return results;
    }
double calculateRS(ut1,dt1) => ut1/dt1;


