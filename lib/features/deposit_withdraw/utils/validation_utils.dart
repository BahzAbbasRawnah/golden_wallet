import 'package:golden_wallet/config/constants.dart';

/// Utility class for validating deposit/withdraw form inputs
class DepositWithdrawValidationUtils {
  /// Validate amount
  static String? validateAmount(String? value, double maxAmount) {
    if (value == null || value.isEmpty) {
      return 'required_field';
    }
    
    // Remove currency symbol and commas
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Try to parse the value
    double? amount;
    try {
      amount = double.parse(cleanValue);
    } catch (e) {
      return 'invalid_amount';
    }
    
    // Check if the amount is within the allowed range
    if (amount < AppConstants.minTransactionAmount) {
      return 'amount_too_small';
    }
    
    if (amount > AppConstants.maxTransactionAmount) {
      return 'amount_too_large';
    }
    
    // Check if the amount is less than or equal to the max amount (for withdrawals)
    if (amount > maxAmount) {
      return 'insufficient_balance';
    }
    
    return null;
  }
  
  /// Validate bank name
  static String? validateBankName(String? value) {
    if (value == null || value.isEmpty) {
      return 'required_field';
    }
    
    if (value.length < 2) {
      return 'bank_name_too_short';
    }
    
    return null;
  }
  
  /// Validate account number
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'required_field';
    }
    
    // Account number should be numeric and at least 8 digits
    if (!RegExp(r'^\d{8,}$').hasMatch(value)) {
      return 'invalid_account_number';
    }
    
    return null;
  }
  
  /// Validate account holder name
  static String? validateAccountHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'required_field';
    }
    
    if (value.length < 3) {
      return 'name_too_short';
    }
    
    return null;
  }
  
  /// Validate IBAN (optional)
  static String? validateIBAN(String? value) {
    if (value == null || value.isEmpty) {
      return null; // IBAN is optional
    }
    
    // Basic IBAN validation - should be alphanumeric and at least 15 characters
    if (!RegExp(r'^[A-Z0-9]{15,34}$').hasMatch(value.toUpperCase())) {
      return 'invalid_iban';
    }
    
    return null;
  }
  
  /// Validate SWIFT/BIC code (optional)
  static String? validateSwiftCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // SWIFT code is optional
    }
    
    // SWIFT/BIC code should be 8 or 11 characters
    if (!RegExp(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$').hasMatch(value.toUpperCase())) {
      return 'invalid_swift_code';
    }
    
    return null;
  }
  
  /// Validate card number
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'required_field';
    }
    
    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Card number should be numeric and 13-19 digits
    if (!RegExp(r'^\d{13,19}$').hasMatch(cleanValue)) {
      return 'invalid_card_number';
    }
    
    // Luhn algorithm check (basic credit card validation)
    if (!_isValidCardNumber(cleanValue)) {
      return 'invalid_card_number';
    }
    
    return null;
  }
  
  /// Validate card holder name
  static String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'required_field';
    }
    
    if (value.length < 3) {
      return 'name_too_short';
    }
    
    return null;
  }
  
  /// Validate card expiry date
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'required_field';
    }
    
    // Expiry date should be in MM/YY format
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'invalid_expiry_date';
    }
    
    // Extract month and year
    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) {
      return 'invalid_expiry_date';
    }
    
    // Check if month is valid (1-12)
    if (month < 1 || month > 12) {
      return 'invalid_month';
    }
    
    // Check if the card is not expired
    final now = DateTime.now();
    final currentYear = now.year % 100; // Get last two digits of the year
    final currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'card_expired';
    }
    
    return null;
  }
  
  /// Validate CVV
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'required_field';
    }
    
    // CVV should be 3 or 4 digits
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'invalid_cvv';
    }
    
    return null;
  }
  
  /// Validate reference number (optional)
  static String? validateReference(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Reference is optional
    }
    
    // Reference should be alphanumeric and at least 3 characters
    if (!RegExp(r'^[A-Za-z0-9]{3,}$').hasMatch(value)) {
      return 'invalid_reference';
    }
    
    return null;
  }
  
  /// Luhn algorithm for credit card validation
  static bool _isValidCardNumber(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
}
