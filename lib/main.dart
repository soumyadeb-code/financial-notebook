// ============================================================
// main.dart
// The entry point of the Flutter app.
//
// Boot sequence (step by step):
//   1. Flutter engine initialized
//   2. DatabaseService created and opens SQLite DB on device
//   3. Repositories created (they use DatabaseService)
//   4. BLoCs created (they use Repositories)
//   5. App runs with all BLoCs provided at the root
//
// Why DatabaseService instead of SharedPreferences?
//   - SQLite is a real relational database
//   - Supports complex queries, joins, indexes, transactions
//   - Much faster for large datasets
//   - Data is structured and typed, not just JSON blobs
//   - Atomic transactions: bank balance + transaction saved together
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'blocs/bank/bank_bloc.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/contact/contact_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/theme/theme_cubit.dart';
import 'core/storage/database_service.dart';
import 'data/repositories/bank_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/contact_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/user_repository.dart';

void main() async {
  // Step 1: MUST be called before using Flutter plugins or async in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Open the SQLite database
  // This creates the .db file on the device if it doesn't exist yet,
  // and creates all the tables on first launch.
  final dbService = DatabaseService();
  await dbService.init();

  // Step 3: Create repositories
  // Each repository talks to the database for one type of data
  final userRepository     = UserRepository(dbService);
  final bankRepository     = BankRepository(dbService);
  final contactRepository  = ContactRepository(dbService);
  final categoryRepository = CategoryRepository(dbService);
  final transactionRepository = TransactionRepository(dbService);

  // Step 4: Launch the app with all BLoCs available everywhere
  runApp(
    MultiBlocProvider(
      providers: [
        // UserBloc: authentication, name, PIN, biometrics
        BlocProvider(
          create: (_) => UserBloc(userRepository),
        ),

        // ThemeCubit: Light/Dark mode
        BlocProvider(
          create: (_) => ThemeCubit(),
        ),

        // BankBloc: bank account CRUD + net worth
        BlocProvider(
          create: (_) => BankBloc(bankRepository),
        ),

        // ContactBloc: people you transact with
        BlocProvider(
          create: (_) => ContactBloc(contactRepository),
        ),

        // CategoryBloc: spending/earning categories (seeds defaults)
        BlocProvider(
          create: (_) => CategoryBloc(
            categoryRepository: categoryRepository,
            userRepository: userRepository,
          ),
        ),

        // TransactionBloc: all money movements + atomic balance updates
        BlocProvider(
          create: (_) => TransactionBloc(transactionRepository),
        ),
      ],
      child: const ExpenseVaultApp(),
    ),
  );
}
