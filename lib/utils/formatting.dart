class Formatting {
  static String formatCurrency(double amount) {
    if (amount >= 10000000) {
      // 10 million or more
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      // 1 lakh or more
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
