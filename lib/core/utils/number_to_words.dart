class NumberToWords {
  static const List<String> _units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  ];

  static String convert(int amount) {
    if (amount == 0) return 'Zero Rupees Only';
    final str = _convertNumber(amount).replaceAll(RegExp(r'\s+'), ' ').trim();
    return '$str Rupees Only';
  }

  static String _convertNumber(int n) {
    if (n < 20) {
      return _units[n];
    } else if (n < 100) {
      return '${_tens[n ~/ 10]} ${_units[n % 10]}';
    } else if (n < 1000) {
      return '${_units[n ~/ 100]} Hundred ${_convertNumber(n % 100)}';
    } else if (n < 100000) {
      return '${_convertNumber(n ~/ 1000)} Thousand ${_convertNumber(n % 1000)}';
    } else if (n < 10000000) {
      return '${_convertNumber(n ~/ 100000)} Lakh ${_convertNumber(n % 100000)}';
    } else {
      return '${_convertNumber(n ~/ 10000000)} Crore ${_convertNumber(n % 10000000)}';
    }
  }
}
