import 'package:intl/intl.dart';

/// Utility class for formatting deposit/withdraw related values
class DepositWithdrawFormattingUtils {
  /// Format currency amount
  static String formatCurrency(double amount, {String currencyCode = 'USD'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: currencyCode == 'USD' ? '\$' : currencyCode,
      decimalDigits: 2,
    );
    
    return formatter.format(amount);
  }
  
  /// Format gold weight
  static String formatGoldWeight(double weight, {String unit = 'oz'}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${formatter.format(weight)} $unit';
  }
  
  /// Format percentage
  static String formatPercentage(double percentage) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${formatter.format(percentage)}%';
  }
  
  /// Format date
  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy', 'en_US');
    return formatter.format(date);
  }
  
  /// Format time
  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm', 'en_US');
    return formatter.format(time);
  }
  
  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm', 'en_US');
    return formatter.format(dateTime);
  }
  
  /// Format card number with masking
  static String formatCardNumber(String cardNumber) {
    // Remove any non-digit characters
    final digitsOnly = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    // Mask all but the last 4 digits
    if (digitsOnly.length > 4) {
      final lastFour = digitsOnly.substring(digitsOnly.length - 4);
      final maskedPart = '*' * (digitsOnly.length - 4);
      
      // Format with spaces for readability
      final formatted = _insertSpacesEvery4Chars(maskedPart + lastFour);
      return formatted;
    }
    
    return digitsOnly;
  }
  
  /// Format card expiry date
  static String formatExpiryDate(String expiryDate) {
    // Remove any non-digit characters
    final digitsOnly = expiryDate.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length >= 2) {
      final month = digitsOnly.substring(0, 2);
      final year = digitsOnly.length > 2 ? digitsOnly.substring(2) : '';
      
      return '$month${year.isNotEmpty ? '/$year' : ''}';
    }
    
    return digitsOnly;
  }
  
  /// Format bank account number with masking
  static String formatAccountNumber(String accountNumber) {
    // Remove any non-digit characters
    final digitsOnly = accountNumber.replaceAll(RegExp(r'\D'), '');
    
    // Mask all but the last 4 digits
    if (digitsOnly.length > 4) {
      final lastFour = digitsOnly.substring(digitsOnly.length - 4);
      final maskedPart = '*' * (digitsOnly.length - 4);
      
      return '$maskedPart$lastFour';
    }
    
    return digitsOnly;
  }
  
  /// Helper method to insert spaces every 4 characters
  static String _insertSpacesEvery4Chars(String input) {
    final buffer = StringBuffer();
    
    for (int i = 0; i < input.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(input[i]);
    }
    
    return buffer.toString();
  }
}
