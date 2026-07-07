# 📒 Financial Notebook

> A beautifully crafted personal finance tracker built with Flutter & BLoC — manage your money with style.

![Flutter](https://img.shields.io/badge/Flutter-3.13-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

---

## ✨ Features

### 💰 Core Finance
- **Bank Account Management** — Add and manage multiple bank accounts with balance tracking
- **Transaction Tracking** — Record credit, debit, and transfer transactions with categories
- **Contact-Based Transfers** — Link transactions to contacts and track money owed/received per person
- **Category Management** — Create custom categories with icons and colors

### 📊 Analytics & Reports
- **Overview Dashboard** — Net worth summary with income vs expense breakdown
- **Daily Tracker** — Day-by-day credit/debit totals with a date picker
- **Charts** — Daily, weekly, monthly, yearly bar charts for:
  - Income vs Expenses by category
  - Contact-wise debit/credit history
- **History Screen** — Full searchable, filterable transaction log

### 🔐 Security
- **6-Digit PIN** — Secure app entry with PIN setup and verification
- **Biometric Login** — Face ID & Fingerprint support via `local_auth`
- **PIN Change** — Update PIN anytime from Settings

### 🎨 Appearance
- **Dark Mode** (default) — Sleek deep purple & dark navy palette
- **Light Mode** — Clean white & soft grey palette
- **Toggle** — Instant theme switch from Settings

### 📇 Contacts
- **Contact Book** — Add payees/payers linked to transactions
- **Auto-suggest** — Contact suggestions in the transaction dialog

---

## 🏗️ Architecture

```
lib/
├── blocs/                  # Business Logic (BLoC / Cubit)
│   ├── bank/
│   ├── category/
│   ├── contact/
│   ├── theme/              # ThemeCubit — dark/light mode
│   ├── transaction/
│   └── user/               # Auth, PIN, biometrics
├── core/
│   ├── constants/          # AppColors, AppStrings, AppTextStyles
│   ├── storage/            # SQLite DatabaseService
│   └── theme/              # AppTheme (dark + light ThemeData)
├── data/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── screens/
    │   ├── home/
    │   ├── history/
    │   ├── onboarding/
    │   ├── report/
    │   └── splash/
    └── widgets/
```

**Pattern:** Feature-first BLoC/Cubit with Repository pattern over SQLite.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.13.0
- Dart >= 3.0

### Installation

```bash
git clone https://github.com/YOUR_USERNAME/financial-notebook.git
cd financial-notebook
flutter pub get
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# Web
flutter build web --no-tree-shake-icons
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (BLoC + Cubit) |
| `sqflite` | Local SQLite database |
| `local_auth` | Biometric authentication |
| `fl_chart` | Charts for analytics |
| `equatable` | Value equality for states |
| `crypto` | SHA-256 PIN hashing |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

MIT License — Copyright (c) 2026 Financial Notebook Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
