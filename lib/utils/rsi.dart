//Reference: https://www.youtube.com/watch?v=Dt0KQg52c6c
class RSIIndicator {
  int n;

  RSIIndicator([this.n = 14]);

  List<double> calculate({required List<double> close}) {
    
    var res = <double>[];
    int firstBar = n + 1;
    var gain = [];
    var loss = [];

    double sumGain = 0, sumLoss = 0;
    double div = 0;
    for (int i = 1; i < close.length; i++) {
      div++;
      double change = close[i] - close[i - 1];
      if (change > 0) {
        sumGain += change;
      } else {
        sumLoss += change.abs();
      }
      if (i == firstBar) {
        gain.add(sumGain / div);
        loss.add(sumLoss / div);
      } else if (i > firstBar) {
        var up = change > 0 ? change : 0;
        var down = change < 0 ? change.abs() : 0;
        var focusGain = (gain.last * (n - 1) + up) / n;
        var focusLoss = (loss.last * (n - 1) + down) / n;
        gain.add(focusGain);
        loss.add(focusLoss);
      }
    }
    for (int i = 0; i < gain.length; i++) {
      double rs = gain[i] / loss[i].abs();
      double rsi = 100 - 100 / (1 + rs);
      res.add(rsi);
    }
    return res;
  }
}
