import 'package:intl/intl.dart';

/// Currency / price formatting utilities (Hungarian Forint).
class PriceFormatter {
  PriceFormatter._();

  static final _fmt = NumberFormat('#,##0', 'en_US');
  static final _fmtDecimal = NumberFormat('#,##0.##', 'en_US');

  /// Format price as "1,234 Ft" (no decimals for whole numbers).
  static String format(double price) {
    if (price == price.roundToDouble()) {
      return '${_fmt.format(price.toInt())} Ft';
    }
    return '${_fmtDecimal.format(price)} Ft';
  }

  /// Format price compactly: "1.2K Ft", "3.5M Ft".
  static String formatCompact(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M Ft';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K Ft';
    }
    return format(price);
  }
}
