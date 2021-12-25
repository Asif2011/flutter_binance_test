
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



  Map<String, String>? filterSymbols(String symbol, {List<String> quoteSymbols = const [
    'BTC',
    'ETH',
    'BNB',
    'USDT',
    'PAX',
    'TUSD',
    'USDC',
    'XRP',
    'BUSD',
    'USDS'
  ],})
 {
  Map<String, String>? result;
  String filteredSymbol = '';
  String myRegularExp = "";
  //     "r\"^(\w+)(BTC|ETH|BNB|USDT|PAX|TUSD|USDC|XRP|BUSD|USDS)\$";

  quoteSymbols.forEach((element) {
    int index = quoteSymbols.indexOf(element);
    myRegularExp =
        index == 0 ? myRegularExp + element : myRegularExp + "|" + element;
  });
  myRegularExp = r"^(\w+)(" + myRegularExp + r")$";
  RegExp exp = RegExp("$myRegularExp");
  // RegExp exp = RegExp(r"^(\w+)(USDT)$");
  Iterable<RegExpMatch> matches = exp.allMatches(symbol);
  if (matches.isNotEmpty) {
    filteredSymbol = symbol;
    String baseSymbol = matches.elementAt(0).group(1)!;
    String quoteSymbol = matches.elementAt(0).group(2)!;
    result = {
      "filteredSymbol": filteredSymbol,
      'baseSymbol': baseSymbol,
      "quoteSymbol": quoteSymbol
    };
  }
  // print(result);
  return result;
}

