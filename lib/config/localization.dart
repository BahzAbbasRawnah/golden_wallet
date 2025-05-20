import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

/// Localization configuration for the GoldenWallet application
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
  ];

  // List of localization delegates
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    // A class which loads the translations from JSON files
    AppLocalizations.delegate,
    // Built-in localization of basic text for Material widgets
    GlobalMaterialLocalizations.delegate,
    // Built-in localization for text direction LTR/RTL
    GlobalWidgetsLocalizations.delegate,
    // Built-in localization of basic text for Cupertino widgets
    GlobalCupertinoLocalizations.delegate,
  ];

  // Determine if the current locale is RTL
  static bool isRtl(BuildContext context) {
    return Directionality.of(context) == TextDirection.RTL;
  }

  // Determine the text direction based on the locale
  static TextDirection getTextDirection(Locale locale) {
    if (locale.languageCode == 'ar') {
      return TextDirection.RTL;
    }
    return TextDirection.LTR;
  }

  // Format currency based on locale
  static String formatCurrency(double amount, {String? currencyCode}) {
    final code = currencyCode ?? 'USD';
    final format = NumberFormat.currency(
      locale: 'en_US',
      symbol: code == 'USD' ? '\$' : code,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  // Format date based on locale
  static String formatDate(DateTime date, {String? pattern}) {
    final format = DateFormat(pattern ?? 'MMM dd, yyyy');
    return format.format(date);
  }

  // Format time based on locale
  static String formatTime(DateTime time, {String? pattern}) {
    final format = DateFormat(pattern ?? 'HH:mm');
    return format.format(time);
  }

  // Format date and time based on locale
  static String formatDateTime(DateTime dateTime, {String? pattern}) {
    final format = DateFormat(pattern ?? 'MMM dd, yyyy HH:mm');
    return format.format(dateTime);
  }

  // Translations
  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    // Load the language JSON file from the assets
    // For now, we'll use a hardcoded map for simplicity
    _localizedStrings =
        locale.languageCode == 'ar' ? _arabicStrings : _englishStrings;
    return true;
  }

  // This method will be called from every widget that needs a localized text
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // English translations
  static const Map<String, String> _englishStrings = {
    // General
    'app_name': 'Golden Wallet',
    'app_description': 'Premium Gold Shop & Smart Wallet',

    // Onboarding
    'onboarding_title_1': 'Welcome to Golden Wallet',
    'onboarding_desc_1':
        'Your premium solution for gold investment and smart wallet management',
    'onboarding_title_2': 'Smart Wallet Features',
    'onboarding_desc_2':
        'Securely manage your gold and cash with our advanced wallet features',
    'onboarding_title_3': 'Gold Investment Benefits',
    'onboarding_desc_3':
        'Invest in gold with confidence and track your portfolio growth',
    'skip': 'Skip',
    'next': 'Next',
    'get_started': 'Get Started',

    // Authentication
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'phone': 'Phone',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'forgot_password': 'Forgot Password?',
    'forgot_password_subtitle':
        'Enter your phone number to receive a verification code',
    'or_login_with': 'Or login with',
    'dont_have_account': 'Don\'t have an account?',
    'already_have_account': 'Already have an account?',
    'sign_up': 'Sign Up',
    'sign_in': 'Sign In',
    'full_name': 'Full Name',
    'identity_number': 'Identity Number',
    'identity_front': 'Identity Card (Front)',
    'identity_back': 'Identity Card (Back)',
    'upload_image': 'Upload Image',
    'take_photo': 'Take Photo',
    'choose_from_gallery': 'Choose from Gallery',
    'tap_to_change': 'Tap to change',
    'continue': 'Continue',
    'verify': 'Verify',
    'verification_code': 'Verification Code',
    'enter_verification_code': 'Enter the verification code sent to your phone',
    'resend_code': 'Resend Code',
    'didnt_receive_code': 'Didn\'t receive the code?',
    'reset_code_sent': 'Reset Code Sent',
    'check_phone_instructions':
        'We\'ve sent a verification code to your phone number',
    'send_reset_code': 'Send Reset Code',
    'remember_password': 'Remember your password?',
    'terms_conditions': 'Terms & Conditions',
    'privacy_policy': 'Privacy Policy',
    'agree_terms': 'I agree to the Terms & Conditions and Privacy Policy',

    // Dashboard
    'dashboard': 'Dashboard',
    'wallet_balance': 'Wallet Balance',
    'gold_balance': 'Gold Balance',
    'cash_balance': 'Cash Balance',
    'transaction_history': 'Transaction History',
    'last_7_days': 'Last 7 Days',
    'last_30_days': 'Last 30 Days',
    'last_90_days': 'Last 90 Days',
    'quick_actions': 'Quick Actions',
    'buy': 'Buy',
    'sell': 'Sell',
    'deposit': 'Deposit',
    'withdraw': 'Withdraw',
    'latest_gold_price': 'Latest Gold Price',
    'price_change': 'Price Change',

    // Navigation
    'home': 'Home',
    'catalog': 'Catalog',
    'investments': 'Investments',
    'transactions': 'Transactions',
    'profile': 'Profile',

    // Buy/Sell
    'buy_gold': 'Buy Gold',
    'sell_gold': 'Sell Gold',
    'gold_type': 'Gold Type',
    'weight': 'Weight',
    'amount': 'Amount',
    'current_price': 'Current Price',
    'total_amount': 'Total Amount',
    'transaction_fee': 'Transaction Fee',
    'tax': 'Tax',
    'payable_amount': 'Payable Amount',
    'receivable_amount': 'Receivable Amount',
    'confirm_transaction': 'Confirm Transaction',
    'transaction_summary': 'Transaction Summary',
    'buy_sell_gold': 'Buy/Sell Gold',
    'buy_now': 'Buy Now',
    'sell_now': 'Sell Now',
    'amount_oz': 'Amount (oz)',
    'total_usd': 'Total (USD)',
    'price_per_oz': 'Price per oz',
    'fee': 'Fee',
    'total': 'Total',

    // Gold Categories
    'gold_grams': 'Gold Grams',
    'gold_pounds': 'Gold Pounds',
    'gold_bars': 'Gold Bars',
    'gold_18k': '18K',
    'gold_20k': '20K',
    'gold_21k': '21K',
    'gold_24k': '24K',
    'pound_1g': '1 Gram',
    'pound_2g': '2 Grams',
    'pound_4g': '4 Grams',
    'pound_8g': '8 Grams',
    'bars_count': 'Bars Count',

    // Payment Methods
    'payment_method': 'Payment Method',
    'wallet_payment': 'Wallet Payment',
    'cash_transfer': 'Cash Transfer',
    'select_payment_method': 'Select Payment Method',

    // Deposit/Withdraw
    'deposit_funds': 'Deposit Funds',
    'withdraw_funds': 'Withdraw Funds',
    'deposit_gold': 'Deposit Gold',
    'withdraw_gold': 'Withdraw Gold',
    'select_method': 'Select Method',
    'bank_transfer': 'Bank Transfer',
    'card_payment': 'Card Payment',
    'physical_gold': 'Physical Gold',
    'cash': 'Cash',
    'upload_receipt': 'Upload Receipt',
    'account_details': 'Account Details',
    'bank_name': 'Bank Name',
    'account_number': 'Account Number',
    'ifsc_code': 'IFSC Code',
    'card_number': 'Card Number',
    'expiry_date': 'Expiry Date',
    'cvv': 'CVV',
    'card_holder_name': 'Card Holder Name',

    // Catalog
    'gold_products': 'Gold Products',
    'filter': 'Filter',
    'sort': 'Sort',
    'grid_view': 'Grid View',
    'list_view': 'List View',
    'product_details': 'Product Details',
    'purity': 'Purity',
    'making_charges': 'Making Charges',
    'add_to_cart': 'Add to Cart',
    'buy_product': 'Buy Now',
    'similar_products': 'Similar Products',
    'product_specifications': 'Product Specifications',
    'shopping_cart': 'Shopping Cart',
    'checkout': 'Checkout',
    'continue_shopping': 'Continue Shopping',

    // Investments
    'investment_plans': 'Investment Plans',
    'active_investments': 'Active Investments',
    'investment_history': 'Investment History',
    'plan_details': 'Plan Details',
    'returns': 'Returns',
    'duration': 'Duration',
    'min_investment': 'Minimum Investment',
    'risk_level': 'Risk Level',
    'low_risk': 'Low Risk',
    'medium_risk': 'Medium Risk',
    'high_risk': 'High Risk',
    'join_plan': 'Join Plan',
    'track_performance': 'Track Performance',
    'compare_plans': 'Compare Plans',
    'investment_amount': 'Investment Amount',
    'expected_returns': 'Expected Returns',
    'maturity_date': 'Maturity Date',
    'investment_date': 'Investment Date',

    // Transactions
    'all_transactions': 'All Transactions',
    'view_all': 'View All',
    'pending': 'Pending',
    'completed': 'Completed',
    'failed': 'Failed',
    'cancelled': 'Cancelled',
    'date_range': 'Date Range',
    'transaction_type': 'Transaction Type',
    'transaction_id': 'Transaction ID',
    'transaction_date': 'Transaction Date',
    'transaction_status': 'Transaction Status',
    'transaction_details': 'Transaction Details',
    'export_pdf': 'Export as PDF',
    'export_csv': 'Export as CSV',
    'search_transactions': 'Search transactions...',
    'reset_filters': 'Reset Filters',
    'start_date': 'Start Date',
    'end_date': 'End Date',
    'select_date': 'Select Date',
    'all': 'All',
    'transfer': 'Transfer',
    'investment': 'Investment',
    'transactions_found': 'Transactions Found',
    'no_transactions_found': 'No Transactions Found',
    'try_different_filters':
        'Try different filters or reset to see all transactions',
    'transaction_report': 'Transaction Report',
    'export_success': 'Export successful',
    'export_failed': 'Export failed',
    'payment_details': 'Payment Details',
    'notes': 'Notes',
    'share': 'Share',
    'report_issue': 'Report Issue',
    'share_not_implemented': 'Share functionality not implemented yet',
    'report_not_implemented': 'Report functionality not implemented yet',
    'cancel_not_implemented': 'Cancel functionality not implemented yet',
    'transaction_not_found': 'Transaction not found',
    'sorted_newest_first': 'Sorted: Newest First',
    'sorted_oldest_first': 'Sorted: Oldest First',
    'bank_transfer_payment': 'Bank Transfer',
    'card_payment_method': 'Card Payment',
    'cash_payment': 'Cash',
    'reference_number': 'Reference',
    'buy_success': 'Purchase successful',
    'sell_success': 'Sale successful',

    // Notifications
    'notifications': 'Notifications',
    'mark_all_read': 'Mark All as Read',
    'clear_all': 'Clear All',
    'no_notifications': 'No Notifications',

    // Settings
    'settings': 'Settings',
    'account_settings': 'Account Settings',
    'personal_information': 'Personal Information',
    'security': 'Security',
    'notification_preferences': 'Notification Preferences',
    'appearance': 'Appearance',
    'language': 'Language',
    'theme': 'Theme',
    'light_mode': 'Light Mode',
    'dark_mode': 'Dark Mode',
    'system_default': 'System Default',
    'english': 'English',
    'arabic': 'العربية',
    'logout': 'Logout',
    'delete_account': 'Delete Account',
    'cancel': 'Cancel',

    // Admin
    'admin_dashboard': 'Admin Dashboard',
    'user_management': 'User Management',
    'gold_price_management': 'Gold Price Management',
    'investment_package_management': 'Investment Package Management',
    'analytics': 'Analytics',
    'user_details': 'User Details',
    'account_status': 'Account Status',
    'active': 'Active',
    'inactive': 'Inactive',
    'suspended': 'Suspended',
    'update_gold_price': 'Update Gold Price',
    'publish': 'Publish',
    'schedule_update': 'Schedule Update',

    // Errors and Messages
    'error_occurred': 'An error occurred',
    'try_again': 'Try Again',
    'success': 'Success',
    'loading': 'Loading...',
    'no_data': 'No data available',
    'required_field': 'This field is required',
    'invalid_email': 'Invalid email address',
    'invalid_phone': 'Invalid phone number',
    'invalid_identity': 'Invalid identity number',
    'password_short': 'Password must be at least 8 characters',
    'passwords_not_match': 'Passwords do not match',
    'invalid_amount': 'Invalid amount',
    'insufficient_balance': 'Insufficient balance',
    'transaction_successful': 'Transaction successful',
    'transaction_failed': 'Transaction failed',
    'both_identity_images_required': 'Both identity card images are required',
    'identity_front_required': 'Front side of identity card is required',
    'identity_back_required': 'Back side of identity card is required',
    'coming_soon': 'Coming Soon',
  };

  // Arabic translations
  static const Map<String, String> _arabicStrings = {
    // General
    'app_name': 'المحفظة الذهبية',
    'app_description': 'محفظة ذكية ومتجر ذهب متميز',

    // Onboarding
    'onboarding_title_1': 'مرحبًا بك في المحفظة الذهبية',
    'onboarding_desc_1': 'حلك المتميز لاستثمار الذهب وإدارة المحفظة الذكية',
    'onboarding_title_2': 'ميزات المحفظة الذكية',
    'onboarding_desc_2': 'إدارة الذهب والنقد بأمان مع ميزات محفظتنا المتقدمة',
    'onboarding_title_3': 'فوائد استثمار الذهب',
    'onboarding_desc_3': 'استثمر في الذهب بثقة وتتبع نمو محفظتك',
    'skip': 'تخطي',
    'next': 'التالي',
    'get_started': 'ابدأ الآن',

    // Authentication
    'login': 'تسجيل الدخول',
    'register': 'التسجيل',
    'email': 'البريد الإلكتروني',
    'phone': 'الهاتف',
    'password': 'كلمة المرور',
    'confirm_password': 'تأكيد كلمة المرور',
    'forgot_password': 'نسيت كلمة المرور؟',
    'forgot_password_subtitle': 'أدخل رقم هاتفك لتلقي رمز التحقق',
    'or_login_with': 'أو سجل الدخول باستخدام',
    'dont_have_account': 'ليس لديك حساب؟',
    'already_have_account': 'لديك حساب بالفعل؟',
    'sign_up': 'إنشاء حساب',
    'sign_in': 'تسجيل الدخول',
    'full_name': 'الاسم الكامل',
    'identity_number': 'رقم الهوية',
    'identity_front': 'بطاقة الهوية (الأمام)',
    'identity_back': 'بطاقة الهوية (الخلف)',
    'upload_image': 'تحميل صورة',
    'take_photo': 'التقاط صورة',
    'choose_from_gallery': 'اختيار من المعرض',
    'tap_to_change': 'اضغط للتغيير',
    'continue': 'متابعة',
    'verify': 'تحقق',
    'verification_code': 'رمز التحقق',
    'enter_verification_code': 'أدخل رمز التحقق المرسل إلى هاتفك',
    'resend_code': 'إعادة إرسال الرمز',
    'didnt_receive_code': 'لم تستلم الرمز؟',
    'reset_code_sent': 'تم إرسال رمز إعادة التعيين',
    'check_phone_instructions': 'لقد أرسلنا رمز التحقق إلى رقم هاتفك',
    'send_reset_code': 'إرسال رمز إعادة التعيين',
    'remember_password': 'تتذكر كلمة المرور؟',
    'terms_conditions': 'الشروط والأحكام',
    'privacy_policy': 'سياسة الخصوصية',
    'agree_terms': 'أوافق على الشروط والأحكام وسياسة الخصوصية',

    // Dashboard
    'dashboard': 'لوحة التحكم',
    'wallet_balance': 'رصيد المحفظة',
    'gold_balance': 'رصيد الذهب',
    'cash_balance': 'الرصيد النقدي',
    'transaction_history': 'سجل المعاملات',
    'last_7_days': 'آخر 7 أيام',
    'last_30_days': 'آخر 30 يوم',
    'last_90_days': 'آخر 90 يوم',
    'quick_actions': 'إجراءات سريعة',
    'buy': 'شراء',
    'sell': 'بيع',
    'deposit': 'إيداع',
    'withdraw': 'سحب',
    'latest_gold_price': 'أحدث سعر للذهب',
    'price_change': 'تغير السعر',

    // Navigation
    'home': 'الرئيسية',
    'catalog': 'المنتجات',
    'investments': 'الاستثمارات',
    'transactions': 'المعاملات',
    'profile': 'الملف الشخصي',

    // Buy/Sell
    'buy_gold': 'شراء الذهب',
    'sell_gold': 'بيع الذهب',
    'gold_type': 'نوع الذهب',
    'weight': 'الوزن',
    'amount': 'المبلغ',
    'current_price': 'السعر الحالي',
    'total_amount': 'المبلغ الإجمالي',
    'transaction_fee': 'رسوم المعاملة',
    'tax': 'الضريبة',
    'payable_amount': 'المبلغ المستحق',
    'receivable_amount': 'المبلغ المستحق استلامه',
    'confirm_transaction': 'تأكيد المعاملة',
    'transaction_summary': 'ملخص المعاملة',
    'transaction_details': 'تفاصيل المعاملة',
    'buy_sell_gold': 'شراء/بيع الذهب',
    'buy_now': 'شراء الآن',
    'sell_now': 'بيع الآن',
    'amount_oz': 'الكمية (أونصة)',
    'total_usd': 'المجموع (دولار)',
    'price_per_oz': 'السعر لكل أونصة',
    'fee': 'الرسوم',
    'total': 'المجموع',

    // Gold Categories
    'gold_grams': 'جرامات الذهب',
    'gold_pounds': 'جنيهات الذهب',
    'gold_bars': 'سبائك الذهب',
    'gold_18k': 'عيار 18',
    'gold_20k': 'عيار 20',
    'gold_21k': 'عيار 21',
    'gold_24k': 'عيار 24',
    'pound_1g': '1 جرام',
    'pound_2g': '2 جرام',
    'pound_4g': '4 جرام',
    'pound_8g': '8 جرام',
    'bars_count': 'عدد السبائك',

    // Payment Methods
    'payment_method': 'طريقة الدفع',
    'wallet_payment': 'الدفع من المحفظة',
    'cash_transfer': 'تحويل نقدي',
    'select_payment_method': 'اختر طريقة الدفع',

    // Settings
    'settings': 'الإعدادات',
    'account_settings': 'إعدادات الحساب',
    'personal_information': 'المعلومات الشخصية',
    'security': 'الأمان',
    'notification_preferences': 'تفضيلات الإشعارات',
    'appearance': 'المظهر',
    'language': 'اللغة',
    'theme': 'السمة',
    'light_mode': 'الوضع الفاتح',
    'dark_mode': 'الوضع الداكن',
    'system_default': 'إعدادات النظام',
    'english': 'English',
    'arabic': 'العربية',
    'logout': 'تسجيل الخروج',
    'delete_account': 'حذف الحساب',
    'cancel': 'إلغاء',

    // Error messages
    'both_identity_images_required': 'يجب تحميل صورة الهوية من الأمام والخلف',
    'identity_front_required': 'يجب تحميل صورة الهوية من الأمام',
    'identity_back_required': 'يجب تحميل صورة الهوية من الخلف',
    'invalid_identity': 'رقم الهوية غير صالح',
    'coming_soon': 'قريباً',

    // More translations would be added here...
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
