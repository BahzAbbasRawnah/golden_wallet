# Golden Wallet

Golden Wallet is a premium Flutter application designed for gold investment, smart wallet management, and e-commerce of gold products. The app provides a seamless experience for users to buy, sell, and manage gold assets, as well as shop for gold products, all within a secure and modern digital wallet.

## Project Idea
Golden Wallet aims to make gold investment and trading accessible, transparent, and user-friendly. It combines the features of a digital wallet, gold investment platform, and e-commerce store for gold products, targeting users who want to invest in, buy, or sell gold securely and efficiently.

## Main Features
- **User Authentication**: Secure login, registration, and identity verification.
- **Dashboard**: Overview of wallet balance, gold balance, cash balance, and recent transactions.
- **Buy/Sell Gold**: Intuitive screens for buying and selling gold in various forms (grams, pounds, bars) with real-time pricing and payment options (wallet, cash transfer).
- **Product Catalog**: Browse, search, and filter a wide range of gold products with detailed product pages and specifications.
- **Product Details**: View product images, prices (with discounts), specifications, and similar products.
- **Cart & Checkout**: Add products to cart and complete purchases securely.
- **Investment Plans**: Explore and join gold investment plans with performance tracking.
- **Transaction History**: View all past transactions with filtering and export options.
- **Favorites**: Mark products as favorites for quick access.
- **Localization**: Full support for English and Arabic languages, including RTL layout.
- **Theming**: Modern light and dark themes with gold-accented UI.
- **Admin Panel**: (If enabled) Manage users, gold prices, and investment packages.

## Technology Stack
- **Framework**: [Flutter](https://flutter.dev/) (cross-platform for Android & iOS)
- **Programming Language**: Dart
- **State Management**: Provider
- **Localization**: easy_localization, custom localization system
- **UI Components**: Custom widgets for dropdowns, text fields, cards, buttons, etc.
- **Navigation**: Named routes
- **Testing**: Widget and unit tests

## Project Structure
- `lib/` - Main source code
  - `features/` - Modular features (buy_sell, catalog, dashboard, auth, etc.)
  - `shared/` - Reusable widgets and utilities
  - `config/` - App configuration (theme, routes, localization)
  - `core/` - Core logic and providers
- `assets/` - Fonts, images, icons, animations, and translations
- `test/` - Test files

## Supported Languages
- English
- Arabic (RTL)

## Themes
- Light and Dark modes
- Gold-accented color palette for a premium look

## Recommended Database
- For production: **Firebase Firestore** or **Supabase** for real-time sync, scalability, and security.
- For local development or offline: **SQLite** (via sqflite package).

## How to Run
1. Install Flutter SDK and dependencies.
2. Run `flutter pub get` to fetch packages.
3. Use `flutter run` to launch the app on an emulator or device.

## Assets
- Custom fonts (SF Pro, Roboto)
- Gold-themed icons and images
- Lottie animations for success and onboarding

## Security
- Secure authentication and data handling
- Follows best practices for sensitive data and user privacy

## Contribution
Pull requests are welcome! Please open issues for suggestions or bug reports.

## License
This project is licensed under the MIT License.