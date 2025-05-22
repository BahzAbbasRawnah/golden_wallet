/// Constants used throughout the application
class AppConstants {
  // App information
  static const String appName = 'Golden Wallet';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Premium Gold Shop & Smart Wallet';

  // Routes
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeResetPassword = '/reset-password';
  static const String routePhoneVerification = '/phone-verification';
  static const String routeDashboard = '/dashboard';
  static const String routeBuySell = '/buy-sell';
  static const String routeGoldPriceHistory = '/gold-price-history';
  static const String routeDepositWithdraw = '/deposit-withdraw';
  static const String routeCatalog = '/catalog';
  static const String routeCart = '/cart';
  static const String routeCheckout = '/checkout';
  static const String routeProductDetail = '/product-detail';
  static const String routeInvestment = '/investment';
  static const String routeInvestmentDetail = '/investment-detail';
  static const String routeTransactions = '/transactions';
  static const String routeTransactionDetail = '/transaction-detail';
  static const String routeNotifications = '/notifications';
  static const String routeNotificationDetail = '/notification-detail';
  static const String routeSettings = '/settings';
  static const String routeProfile = '/profile';
  static const String routeAdmin = '/admin';

  // Additional investment routes
  static const String routeInvestmentOnboarding = '/investment-onboarding';
  static const String routeInvestmentPlans = '/investment-plans';
  static const String routeInvestmentPlanDetail = '/investment-plan-detail';
  static const String routeInvestmentPurchase = '/investment-purchase';
  static const String routeInvestmentConfirmation = '/investment-confirmation';
  static const String routeInvestmentSuccess = '/investment-success';
  static const String routeInvestmentManagement = '/investment-management';
  static const String routeGoldPriceManagement = '/gold-price-management';

  // Shared preferences keys
  static const String prefIsFirstLaunch = 'is_first_launch';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefUserToken = 'user_token';
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';

  // API endpoints (placeholder)
  static const String apiBaseUrl = 'https://api.goldenwallet.example.com';
  static const String apiLogin = '/auth/login';
  static const String apiRegister = '/auth/register';
  static const String apiForgotPassword = '/auth/forgot-password';
  static const String apiGoldPrices = '/gold/prices';
  static const String apiTransactions = '/transactions';
  static const String apiProducts = '/products';
  static const String apiInvestments = '/investments';
  static const String apiUserProfile = '/user/profile';

  // Gold types
  static const Map<String, double> goldPurity = {
    '24K': 0.999,
    '22K': 0.916,
    '18K': 0.750,
    '14K': 0.585,
  };

  // Transaction types
  static const String transactionTypeBuy = 'buy';
  static const String transactionTypeSell = 'sell';
  static const String transactionTypeDeposit = 'deposit';
  static const String transactionTypeWithdraw = 'withdraw';
  static const String transactionTypeTransfer = 'transfer';
  static const String transactionTypeInvestment = 'investment';

  // Transaction status
  static const String transactionStatusPending = 'pending';
  static const String transactionStatusCompleted = 'completed';
  static const String transactionStatusFailed = 'failed';
  static const String transactionStatusCancelled = 'cancelled';

  // User roles
  static const String userRoleCustomer = 'customer';
  static const String userRoleAdmin = 'admin';
  static const String userRoleManager = 'manager';

  // Notification types
  static const String notificationTypeTransaction = 'transaction';
  static const String notificationTypePriceAlert = 'price_alert';
  static const String notificationTypeSystem = 'system';
  static const String notificationTypePromotion = 'promotion';

  // Investment plan types
  static const String investmentTypeFixed = 'fixed';
  static const String investmentTypeFlexible = 'flexible';
  static const String investmentTypeSIP = 'sip'; // Systematic Investment Plan

  // Risk levels
  static const String riskLevelLow = 'low';
  static const String riskLevelMedium = 'medium';
  static const String riskLevelHigh = 'high';

  // Payment methods
  static const String paymentMethodBank = 'bank_transfer';
  static const String paymentMethodCard = 'card';
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodGold = 'physical_gold';

  // Languages
  static const String languageEnglish = 'en';
  static const String languageArabic = 'ar';

  // Validation
  static const int passwordMinLength = 8;
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 1000000;

  // Animation durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 500);
  static const Duration animationDurationLong = Duration(milliseconds: 800);
}
