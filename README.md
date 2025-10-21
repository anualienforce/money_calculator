# Cash Calculator

A comprehensive Flutter app for mobile devices that replicates the exact UI design from the provided image, with advanced features for managing cash calculations and transactions.

## 🚀 Features

### Core Functionality
- **Cash Denomination Calculator**: Input quantities for different cash denominations (10, 5, 2, 1, 0.50, 0.25, 0.10, 0.05, 0.01)
- **Real-time Calculations**: Automatically calculates totals as you input quantities
- **Online Amount**: Add online/electronic payments to the total
- **Amount in Words**: Displays the total amount in words
- **Transaction Management**: Save, view, and manage all calculations

### Advanced Features
- **Side Navigation Drawer**: Easy access to all app features
- **Transaction History**: View, search, and sort all saved transactions
- **Settings Management**: Customize currency, theme, and app preferences
- **Data Persistence**: Local storage using SharedPreferences
- **Export/Import**: Backup and restore transaction data
- **Multiple Currencies**: Support for various currency symbols
- **Dark Mode**: Toggle between light and dark themes

## 📱 UI Components

### Main Calculator Screen
- **App Bar**: Blue header with hamburger menu and "Transactions" button
- **Amount Display**: Shows total amount in words
- **Denomination Rows**: Input fields for each cash denomination
- **Totals Section**: Shows quantity totals, online amount, and grand total
- **Action Buttons**: Clear (Orange), Save (Green), Share (Blue)

### Side Navigation Drawer
- **App Header**: Branded header with app icon and version
- **Menu Items**: Calculator, Transactions, Analytics, Backup, Help, Settings
- **Quick Actions**: Rate app, About, and other utilities

### Transactions Screen
- **Search Bar**: Find transactions by title or notes
- **Statistics**: Total transactions, amount, and monthly counts
- **Transaction Cards**: Detailed view of each saved calculation
- **Sort Options**: Sort by date, amount, or title
- **Delete Function**: Remove unwanted transactions

### Settings Screen
- **Currency Selection**: Choose from multiple currency symbols
- **Theme Toggle**: Switch between light and dark modes
- **Display Options**: Configure amount in words and auto-save
- **Data Management**: Export, import, and clear all data
- **App Information**: Version details and about information

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator for testing

### Installation
```bash
git clone <repository-url>
cd money_calculator
flutter pub get
```

### Run the App
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point
├── models/
│   ├── denomination.dart              # Denomination data model
│   ├── transaction.dart               # Transaction data model
│   └── app_settings.dart              # App settings model
├── screens/
│   ├── main_screen.dart               # Main screen with navigation
│   ├── cash_calculator_screen.dart    # Calculator screen
│   ├── transactions_screen.dart       # Transactions management
│   └── settings_screen.dart           # App settings
├── services/
│   └── data_service.dart              # Data persistence service
└── widgets/
    ├── denomination_row.dart          # Individual denomination input
    ├── total_section.dart             # Totals display section
    ├── action_buttons.dart            # Action buttons
    ├── transaction_card.dart          # Transaction list item
    └── save_transaction_dialog.dart   # Save transaction dialog
```

## 💾 Data Management

### Local Storage
- **SharedPreferences**: Stores transactions and settings locally
- **JSON Serialization**: Efficient data storage and retrieval
- **Data Validation**: Ensures data integrity and consistency

### Transaction Features
- **Save Calculations**: Store calculations with custom titles and notes
- **Search & Filter**: Find transactions quickly
- **Sort Options**: Organize by date, amount, or title
- **Delete Transactions**: Remove unwanted entries
- **Export Data**: Backup transactions to external storage

## 🎨 Customization

### Theme Customization
- **Color Scheme**: Easily modify primary colors and accents
- **Dark Mode**: Toggle between light and dark themes
- **Typography**: Customize fonts and text styles
- **Layout**: Adjust spacing, padding, and component sizes

### Currency Support
- **Multiple Symbols**: Support for $, €, £, ₹, ¥, ₽ and more
- **Easy Switching**: Change currency in settings
- **Consistent Display**: Currency symbol appears throughout the app

### Denominations
- **Customizable Values**: Add or modify denomination values
- **Flexible Input**: Support for various currency formats
- **Real-time Updates**: Instant calculation updates

## 📊 Usage Guide

### Basic Calculation
1. **Open the app** and navigate to the Calculator screen
2. **Input quantities** for each cash denomination
3. **Add online amount** if applicable
4. **View totals** in real-time
5. **Save calculation** with a custom title and notes

### Managing Transactions
1. **Navigate to Transactions** from the side menu or bottom navigation
2. **Search transactions** using the search bar
3. **Sort transactions** by date, amount, or title
4. **View details** by tapping on any transaction card
5. **Delete transactions** using the delete button

### App Settings
1. **Open Settings** from the side menu or bottom navigation
2. **Select currency** from the available options
3. **Toggle dark mode** for better viewing experience
4. **Configure display options** as needed
5. **Manage data** with export/import features

## 🔧 Dependencies

- `flutter`: Flutter SDK
- `cupertino_icons`: Material Design icons
- `shared_preferences`: Local data persistence
- `intl`: Internationalization and date formatting

## 🚀 Future Enhancements

- **Cloud Sync**: Sync data across devices
- **Advanced Analytics**: Charts and reports
- **Receipt Scanning**: OCR for automatic data entry
- **Multi-language Support**: Internationalization
- **Widget Support**: Home screen widgets
- **Export Formats**: PDF, Excel, CSV export options

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support and questions, please open an issue in the repository.# money_calculator
