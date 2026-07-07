// ============================================================
// app_strings.dart
// All user-visible text strings in one place.
// Good practice: keeping strings here makes it easy to
// translate the app to other languages later.
// ============================================================

class AppStrings {
  AppStrings._();

  // ----- App Info -----
  static const String appName = 'Financial Notebook';
  static const String appTagline = 'Personal Finance';

  // ----- Onboarding -----
  static const String welcomeTitle = 'Welcome to\nFinancial Notebook 💰';
  static const String enterNameHint = 'Enter your full name';
  static const String enterNameLabel = 'Your Name';
  static const String continueButton = 'Continue';

  // ----- PIN Screen -----
  static const String setupPinTitle = 'Create Security PIN';
  static const String setupPinSubtitle = 'Choose a 6-digit PIN to secure your vault';
  static const String confirmPinTitle = 'Confirm Your PIN';
  static const String confirmPinSubtitle = 'Enter the same PIN again';
  static const String verifyPinTitle = 'Enter PIN';
  static const String verifyPinSubtitle = 'Enter your 6-digit security PIN';
  static const String pinMismatch = 'PINs do not match. Please try again.';
  static const String pinWrong = 'Incorrect PIN. Please try again.';
  static const String orUseBiometric = 'or use biometrics';
  static const String biometricReason = 'Authenticate to access ExpenseVault';

  // ----- Home -----
  static const String totalNetWorth = 'TOTAL NET WORTH';
  static const String totalIn = 'Total In';
  static const String totalOut = 'Total Out';
  static const String myAccounts = 'My Accounts';
  static const String categories = 'Categories';
  static const String contacts = 'Contacts';
  static const String addTxn = 'Add Txn';
  static const String transfer = 'Transfer';
  static const String addNew = '+ Add';

  // ----- Navigation -----
  static const String navHome = 'Home';
  static const String navHistory = 'History';
  static const String navReport = 'Report';

  // ----- Add Bank -----
  static const String addBank = 'Add Bank Account';
  static const String bankName = 'Bank Name';
  static const String accountType = 'Account Type';
  static const String openingBalance = 'Opening Balance (₹)';
  static const String dateAdded = 'Date Added';
  static const String addBankButton = 'Add Account';

  // ----- Account Types -----
  static const List<String> accountTypes = [
    'Savings',
    'Current',
    'Salary',
    'Credit Card',
    'Wallet',
  ];

  // ----- Add Contact -----
  static const String addContact = 'Add Contact';
  static const String contactName = 'Contact Name';
  static const String addContactButton = 'Add Contact';

  // ----- Add Category -----
  static const String addCategory = 'Add Category';
  static const String categoryName = 'Category Name';
  static const String chooseEmoji = 'Choose Emoji';
  static const String chooseColor = 'Choose Color';
  static const String addCategoryButton = 'Add Category';

  // ----- Add Transaction -----
  static const String addTransaction = 'Add Transaction';
  static const String bankAccount = 'Bank Account';
  static const String transactionType = 'Type';
  static const String credit = 'Credit';
  static const String debit = 'Debit';
  static const String amount = 'Amount (₹)';
  static const String contact = 'Contact';
  static const String category = 'Category';
  static const String note = 'Note';
  static const String date = 'Date';
  static const String searchContact = 'Search contact...';
  static const String searchCategory = 'Search or type category...';
  static const String optionalNote = 'Optional note';
  static const String addTransactionButton = 'Add Transaction';
  static const String optional = 'optional';

  // ----- Transfer -----
  static const String transferMoney = 'Transfer Money';
  static const String fromAccount = 'From Account';
  static const String toAccount = 'To Account';
  static const String transferNote = 'e.g. Monthly savings';
  static const String transferNowButton = 'Transfer Now';

  // ----- Settings -----
  static const String settings = 'Settings';
  static const String changeName = 'Change Name';
  static const String changePin = 'Change PIN';
  static const String biometricLogin = 'Biometric Login';
  static const String about = 'About';

  // ----- History -----
  static const String history = 'History';
  static const String noTransactions = 'No transactions yet.\nAdd one using the + button!';

  // ----- Report -----
  static const String report = 'Report';
  static const String spendingByCategory = 'Spending by Category';
  static const String week = 'Week';
  static const String month = 'Month';
  static const String year = 'Year';

  // ----- Default Categories (pre-seeded on first launch) -----
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Food & Dining', 'emoji': '🍔', 'color': 0xFFF59E0B},
    {'name': 'Transport', 'emoji': '🚗', 'color': 0xFF3B82F6},
    {'name': 'Shopping', 'emoji': '🛍️', 'color': 0xFFEC4899},
    {'name': 'Entertainment', 'emoji': '🎬', 'color': 0xFF8B5CF6},
    {'name': 'Health', 'emoji': '💊', 'color': 0xFF22C55E},
    {'name': 'Education', 'emoji': '📚', 'color': 0xFF06B6D4},
    {'name': 'Salary', 'emoji': '💼', 'color': 0xFF06B6D4},
    {'name': 'Bills', 'emoji': '🧾', 'color': 0xFFEF4444},
    {'name': 'Savings', 'emoji': '💰', 'color': 0xFF22C55E},
    {'name': 'Other', 'emoji': '📦', 'color': 0xFFA0A0B0},
  ];

  // ----- Common Emojis for Category Picker -----
  static const List<String> commonEmojis = [
    '🍔', '🍕', '🍜', '🍣', '🍺', '☕', // Food
    '🚗', '🚌', '✈️', '🚂', '🚢', '⛽', // Transport
    '🛍️', '👗', '👟', '💄', '👜', '🎁', // Shopping
    '🎬', '🎮', '🎵', '📺', '🎭', '🎪', // Entertainment
    '💊', '🏥', '💉', '🏋️', '🧘', '⚽', // Health/Sports
    '📚', '🎓', '✏️', '🖥️', '📱', '📷', // Education/Tech
    '💼', '💰', '🏦', '💳', '🏠', '🔧', // Finance/Work
    '🧾', '📄', '💡', '🌊', '🌿', '🐾', // Utilities/Other
    '❤️', '🎂', '🎉', '🌟', '☀️', '🌙', // Special
  ];
}
