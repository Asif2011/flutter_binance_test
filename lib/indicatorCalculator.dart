/// Returns the larger of two numbers.
///
/// Returns NaN if either argument is NaN.
/// The larger of `-0.0` and `0.0` is `0.0`. If the arguments are
/// otherwise equal (including int and doubles with the same mathematical value)
/// then it is unspecified which of the two arguments is returned.
external T max<T extends num>(T a, T b);

/// Returns the lesser of two numbers.
///
/// Returns NaN if either argument is NaN.
/// The lesser of `-0.0` and `0.0` is `-0.0`.
/// If the arguments are otherwise equal (including int and doubles with the
/// same mathematical value) then it is unspecified which of the two arguments
/// is returned.
external T min<T extends num>(T a, T b);


// static void calcRSI(List<KLineEntity> dataList) {
//     double? rsi;
//     double rsiABSEma = 0;
//     double rsiMaxEma = 0;
//     for (int i = 0; i < dataList.length; i++) {
//       KLineEntity entity = dataList[i];
//       final double closePrice = entity.close;
//       if (i == 0) {
//         rsi = 0;
//         rsiABSEma = 0;
//         rsiMaxEma = 0;
//       } else {
//         double Rmax = max(0, closePrice - dataList[i - 1].close.toDouble());
//         double RAbs = (closePrice - dataList[i - 1].close.toDouble()).abs();

//         rsiMaxEma = (Rmax + (14 - 1) * rsiMaxEma) / 14;
//         rsiABSEma = (RAbs + (14 - 1) * rsiABSEma) / 14;
//         rsi = (rsiMaxEma / rsiABSEma) * 100;
//       }
//       if (i < 13) rsi = null;
//       if (rsi != null && rsi.isNaN) rsi = null;
//       entity.rsi = rsi;
//     }
//   }