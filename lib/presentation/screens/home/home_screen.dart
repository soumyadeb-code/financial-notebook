// ============================================================
// home_screen.dart
// The main screen of the app after login.
// Contains the bottom navigation bar with 3 tabs:
//   0 → Home (dashboard)
//   1 → History (all transactions)
//   2 → Report (charts)
//
// The HomeScreen also loads all BLoC data on first render.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/bank/bank_event.dart';
import '../../../blocs/bank/bank_state.dart';
import '../../../blocs/category/category_bloc.dart';
import '../../../blocs/category/category_event.dart';
import '../../../blocs/category/category_state.dart';
import '../../../blocs/contact/contact_bloc.dart';
import '../../../blocs/contact/contact_event.dart';
import '../../../blocs/contact/contact_state.dart';
import '../../../blocs/transaction/transaction_bloc.dart';
import '../../../blocs/transaction/transaction_event.dart';
import '../../../blocs/user/user_bloc.dart';
import '../../../blocs/user/user_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/dialogs/add_bank_dialog.dart';
import '../../widgets/dialogs/add_category_dialog.dart';
import '../../widgets/dialogs/add_contact_dialog.dart';
import '../../widgets/dialogs/add_transaction_dialog.dart';
import '../../widgets/dialogs/transfer_dialog.dart';
import '../../widgets/home/bank_card_item.dart';
import '../../widgets/home/category_chip.dart';
import '../../widgets/home/contact_item.dart';
import '../../widgets/home/net_worth_card.dart';
import '../history/history_screen.dart';
import '../report/report_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Currently selected bottom nav tab
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load all data when the home screen first opens
    _loadAllData();
  }

  void _loadAllData() {
    // Dispatch Load events to all BLoCs
    context.read<BankBloc>().add(const LoadBanks());
    context.read<TransactionBloc>().add(const LoadTransactions());
    context.read<ContactBloc>().add(const LoadContacts());
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  // The three pages for the bottom nav
  final List<Widget> _pages = const [
    _DashboardTab(),
    HistoryScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ----- App Bar -----
      appBar: _buildAppBar(context),

      // ----- Body: switches between the 3 tabs -----
      // IndexedStack keeps all 3 pages alive (they don't reload on tab switch)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // ----- Bottom Navigation Bar -----
      bottomNavigationBar: _buildBottomNav(),

      // ----- Floating Action Buttons (Add Txn, Transfer) -----
      // These are always visible regardless of tab
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          // App logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('💰', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.appName, style: AppTextStyles.headingSmall),
              // Show the user's name in the app bar
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  final name =
                      state is UserAuthenticated ? state.name : '';
                  return Text(
                    name,
                    style: AppTextStyles.bodySmall,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Settings gear icon
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                        value: context.read<UserBloc>(),
                        child: const SettingsScreen(),
                      )),
            );
          },
          icon: Icon(Icons.settings_outlined,
              color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: AppTextStyles.labelSmall
            .copyWith(color: AppColors.accent),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: AppStrings.navHistory,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: AppStrings.navReport,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _DashboardTab
// The content of the "Home" tab — the main dashboard.
// ============================================================
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // Pull to refresh reloads all data
      onRefresh: () async {
        context.read<BankBloc>().add(const LoadBanks());
        context.read<TransactionBloc>().add(const LoadTransactions());
        context.read<ContactBloc>().add(const LoadContacts());
        context.read<CategoryBloc>().add(const LoadCategories());
      },
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- Net Worth Card -----
            const NetWorthCard(),
            const SizedBox(height: 20),

            // ----- Quick Action Buttons Row -----
            _buildQuickActions(context),
            const SizedBox(height: 28),

            // ----- My Accounts Section -----
            _buildMyAccounts(context),
            const SizedBox(height: 28),

            // ----- Categories Section -----
            _buildCategories(context),
            const SizedBox(height: 28),

            // ----- Contacts Section -----
            _buildContacts(context),
            const SizedBox(height: 80), // Extra padding at bottom
          ],
        ),
      ),
    );
  }

  /// Four quick-action buttons: Add Txn, Transfer, Categories, Contacts
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickAction(
          emoji: '💳',
          label: AppStrings.addTxn,
          color: AppColors.accent,
          onTap: () => showAddTransactionDialog(context),
        ),
        _QuickAction(
          emoji: '🔄',
          label: AppStrings.transfer,
          color: const Color(0xFF3B82F6),
          onTap: () => showTransferDialog(context),
        ),
        _QuickAction(
          emoji: '🏷️',
          label: AppStrings.categories,
          color: const Color(0xFFF59E0B),
          onTap: () => showAddCategoryDialog(context),
        ),
        _QuickAction(
          emoji: '👥',
          label: AppStrings.contacts,
          color: const Color(0xFF8B5CF6),
          onTap: () => showAddContactDialog(context),
        ),
      ],
    );
  }

  /// My Accounts section with list of banks
  Widget _buildMyAccounts(BuildContext context) {
    return Column(
      children: [
        // Section header with "+ Add" button
        _SectionHeader(
          title: AppStrings.myAccounts,
          // After the dialog closes (await), fire LoadBanks so the new
          // bank appears immediately without needing a pull-to-refresh
          onAdd: () async {
            await showAddBankDialog(context);
            if (context.mounted) {
              context.read<BankBloc>().add(const LoadBanks());
            }
          },
        ),
        const SizedBox(height: 12),

        // Bank cards list from BankBloc
        BlocBuilder<BankBloc, BankState>(
          builder: (context, state) {
            if (state is BankLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BankLoaded) {
              if (state.banks.isEmpty) {
                return const _EmptyState(
                  message: 'No bank accounts yet.\nTap + Add to get started!',
                  emoji: '🏦',
                );
              }
              return Column(
                children: state.banks
                    .map((bank) => BankCardItem(
                          bank: bank,
                          onDelete: () {
                            // Show confirmation before deleting
                            _showDeleteConfirm(
                              context,
                              title: 'Delete ${bank.name}?',
                              message:
                                  'This will remove the account but not its transactions.',
                              onConfirm: () {
                                context
                                    .read<BankBloc>()
                                    .add(DeleteBank(bank.id));
                              },
                            );
                          },
                        ))
                    .toList(),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  /// Categories grid
  Widget _buildCategories(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: '🏷️ ${AppStrings.categories}',
          onAdd: () => showAddCategoryDialog(context),
        ),
        const SizedBox(height: 12),

        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoaded) {
              if (state.categories.isEmpty) {
                return const _EmptyState(
                    message: 'No categories yet.', emoji: '🏷️');
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: state.categories.length,
                itemBuilder: (_, i) => CategoryChip(
                  category: state.categories[i],
                  onEdit: () => showAddCategoryDialog(
                    context,
                    categoryToEdit: state.categories[i],
                  ),
                  onDelete: () => _showDeleteConfirm(
                    context,
                    title: 'Delete ${state.categories[i].name}?',
                    message: 'This category will be removed.',
                    onConfirm: () {
                      context
                          .read<CategoryBloc>()
                          .add(DeleteCategory(state.categories[i].id));
                    },
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  /// Contacts list
  Widget _buildContacts(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: '👥 ${AppStrings.contacts}',
          onAdd: () => showAddContactDialog(context),
        ),
        const SizedBox(height: 12),

        BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactLoaded) {
              if (state.contacts.isEmpty) {
                return const _EmptyState(
                    message: 'No contacts yet.', emoji: '👤');
              }
              return Column(
                children: state.contacts
                    .map((c) => ContactItem(
                          contact: c,
                          onDelete: () => _showDeleteConfirm(
                            context,
                            title: 'Delete ${c.name}?',
                            message: 'This contact will be removed.',
                            onConfirm: () {
                              context
                                  .read<ContactBloc>()
                                  .add(DeleteContact(c.id));
                            },
                          ),
                        ))
                    .toList(),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  /// Generic delete confirmation dialog
  void _showDeleteConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.headingSmall),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text('Delete',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.debit)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Helper Widgets (private to this file)
// ============================================================

/// Section header with title and "+ Add" button
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const _SectionHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.headingMedium),
        const Spacer(),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppStrings.addNew,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Quick action button (e.g., Add Txn, Transfer)
class _QuickAction extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Shown when a section has no data yet
class _EmptyState extends StatelessWidget {
  final String message;
  final String emoji;

  const _EmptyState({required this.message, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
