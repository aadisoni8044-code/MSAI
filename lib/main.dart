import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ============================================================================
/// NOVA WEALTH - Modern Finance & Wealth Management Dashboard
/// ============================================================================
/// A production-grade, single-file Flutter application built with Material 3.
/// Features:
/// - Light & Dark Theme Support via ColorScheme.fromSeed
/// - Modern UI/UX with smooth micro-interactions, custom cards & soft shadows
/// - Interactive Cash Flow Line Chart via CustomPainter
/// - Interactive Bottom Navigation (Dashboard, Analytics, Wallet, Settings)
/// - Modal Sheets for "Add Transaction" & "Quick Transfer" with full state updates
/// - Category Filtering, Budget Progress Indicators, & Asset Allocations
/// ============================================================================

void main() {
  // Ensure system overlays are configured cleanly
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const NovaWealthApp());
}

/// Root Widget holding global theme state management using ValueNotifier
class NovaWealthApp extends StatefulWidget {
  const NovaWealthApp({super.key});

  @override
  State<NovaWealthApp> createState() => _NovaWealthAppState();
}

class _NovaWealthAppState extends State<NovaWealthApp> {
  // Global theme mode state switcher (Light <-> Dark)
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.system);

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    if (_themeNotifier.value == ThemeMode.dark) {
      _themeNotifier.value = ThemeMode.light;
    } else {
      _themeNotifier.value = ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Elegant Deep Indigo & Emerald Seed Palette
    const seedColor = Color(0xFF6366F1); // Indigo Primary Accent
    const secondarySeed = Color(0xFF10B981); // Emerald Secondary Accent

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Nova Wealth',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // Light Material 3 Theme Definition
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light,
              secondary: secondarySeed,
              surface: const Color(0xFFF8FAFC),
            ),
            scaffoldBackgroundColor: const Color(0xFFF1F5F9),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: false,
            ),
            fontFamily: 'Roboto',
          ),

          // Dark Material 3 Theme Definition
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
              secondary: secondarySeed,
              surface: const Color(0xFF0F172A),
            ),
            scaffoldBackgroundColor: const Color(0xFF020617),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: const Color(0xFF1E293B),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: false,
            ),
            fontFamily: 'Roboto',
          ),

          home: MainNavigationShell(onToggleTheme: _toggleTheme),
        );
      },
    );
  }
}

// ============================================================================
// DATA MODELS (MOCK BACKEND DATA)
// ============================================================================

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color iconBgColor;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.iconBgColor,
    required this.type,
  });
}

class PaymentCard {
  final String id;
  final String cardHolder;
  final String cardNumber;
  final String expiry;
  final double balance;
  final List<Color> gradientColors;
  final String cardType;

  PaymentCard({
    required this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiry,
    required this.balance,
    required this.gradientColors,
    required this.cardType,
  });
}

class BudgetGoal {
  final String category;
  final double spent;
  final double totalBudget;
  final IconData icon;
  final Color color;

  BudgetGoal({
    required this.category,
    required this.spent,
    required this.totalBudget,
    required this.icon,
    required this.color,
  });

  double get progress => (spent / totalBudget).clamp(0.0, 1.0);
}

// ============================================================================
// MAIN NAVIGATION SHELL WITH BOTTOM NAVIGATION
// ============================================================================

class MainNavigationShell extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const MainNavigationShell({super.key, required this.onToggleTheme});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // Global Mock Account Balance State
  double _totalBalance = 124850.75;
  double _monthlyIncome = 14250.00;
  double _monthlyExpenses = 4820.50;

  // Mock Transactions List
  late List<Transaction> _transactions;
  late List<PaymentCard> _cards;
  late List<BudgetGoal> _budgets;

  @override
  void initState() {
    super.initState();
    _initMockData();
  }

  void _initMockData() {
    _cards = [
      PaymentCard(
        id: '1',
        cardHolder: 'Alex Morgan',
        cardNumber: '•••• •••• •••• 4829',
        expiry: '08/28',
        balance: 84350.25,
        gradientColors: [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
        cardType: 'VISA Platinum',
      ),
      PaymentCard(
        id: '2',
        cardHolder: 'Alex Morgan',
        cardNumber: '•••• •••• •••• 9102',
        expiry: '11/27',
        balance: 40500.50,
        gradientColors: [const Color(0xFF0D9488), const Color(0xFF059669)],
        cardType: 'Mastercard World',
      ),
    ];

    _transactions = [
      Transaction(
        id: 'tx1',
        title: 'Apple Store NYC',
        category: 'Electronics',
        amount: 1299.00,
        date: DateTime.now().subtract(const Duration(hours: 3)),
        icon: Icons.laptop_mac_rounded,
        iconBgColor: const Color(0xFF6366F1),
        type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx2',
        title: 'Stripe Pay Deposit',
        category: 'Freelance Income',
        amount: 4500.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.arrow_downward_rounded,
        iconBgColor: const Color(0xFF10B981),
        type: TransactionType.income,
      ),
      Transaction(
        id: 'tx3',
        title: 'Whole Foods Market',
        category: 'Groceries',
        amount: 184.25,
        date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        icon: Icons.shopping_bag_rounded,
        iconBgColor: const Color(0xFFF59E0B),
        type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx4',
        title: 'Uber Rides',
        category: 'Transport',
        amount: 42.50,
        date: DateTime.now().subtract(const Duration(days: 2)),
        icon: Icons.directions_car_rounded,
        iconBgColor: const Color(0xFFEC4899),
        type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx5',
        title: 'Dividend Payout',
        category: 'Investments',
        amount: 620.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
        icon: Icons.trending_up_rounded,
        iconBgColor: const Color(0xFF3B82F6),
        type: TransactionType.income,
      ),
    ];

    _budgets = [
      BudgetGoal(
        category: 'Shopping & Apparel',
        spent: 1250,
        totalBudget: 1500,
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFF8B5CF6),
      ),
      BudgetGoal(
        category: 'Food & Dining',
        spent: 680,
        totalBudget: 1000,
        icon: Icons.restaurant_outlined,
        color: const Color(0xFFF59E0B),
      ),
      BudgetGoal(
        category: 'Travel & Leisure',
        spent: 320,
        totalBudget: 800,
        icon: Icons.flight_takeoff_outlined,
        color: const Color(0xFF06B6D4),
      ),
      BudgetGoal(
        category: 'Entertainment',
        spent: 190,
        totalBudget: 300,
        icon: Icons.movie_outlined,
        color: const Color(0xFFEC4899),
      ),
    ];
  }

  void _addTransaction(Transaction tx) {
    setState(() {
      _transactions.insert(0, tx);
      if (tx.type == TransactionType.income) {
        _totalBalance += tx.amount;
        _monthlyIncome += tx.amount;
      } else {
        _totalBalance -= tx.amount;
        _monthlyExpenses += tx.amount;
      }
    });
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTransactionBottomSheet(onAddTransaction: _addTransaction),
    );
  }

  void _showQuickTransferModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickTransferBottomSheet(
        onTransfer: (amount, recipient) {
          _addTransaction(
            Transaction(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Transfer to $recipient',
              category: 'Transfer',
              amount: amount,
              date: DateTime.now(),
              icon: Icons.send_rounded,
              iconBgColor: const Color(0xFF8B5CF6),
              type: TransactionType.expense,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        totalBalance: _totalBalance,
        monthlyIncome: _monthlyIncome,
        monthlyExpenses: _monthlyExpenses,
        transactions: _transactions,
        cards: _cards,
        onAddTransaction: _showAddTransactionModal,
        onQuickTransfer: _showQuickTransferModal,
      ),
      AnalyticsScreen(transactions: _transactions, budgets: _budgets),
      WalletScreen(cards: _cards, transactions: _transactions),
      SettingsScreen(onToggleTheme: widget.onToggleTheme),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: pages[_currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        elevation: 10,
        height: 68,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. DASHBOARD OVERVIEW SCREEN
// ============================================================================

class DashboardScreen extends StatefulWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<Transaction> transactions;
  final List<PaymentCard> cards;
  final VoidCallback onAddTransaction;
  final VoidCallback onQuickTransfer;

  const DashboardScreen({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.transactions,
    required this.cards,
    required this.onAddTransaction,
    required this.onQuickTransfer,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'All';

  List<Transaction> get _filteredTransactions {
    if (_selectedFilter == 'Income') {
      return widget.transactions.where((t) => t.type == TransactionType.income).toList();
    } else if (_selectedFilter == 'Expenses') {
      return widget.transactions.where((t) => t.type == TransactionType.expense).toList();
    }
    return widget.transactions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'AM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            'Alex Morgan 👋',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications are all caught up!')),
                      );
                    },
                    icon: const Badge(
                      smallSize: 8,
                      child: Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total Balance Hero Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                        : [const Color(0xFF4338CA), const Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : const Color(0xFF4338CA)).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Worth Balance',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '+14.2%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '\$${widget.totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildIncomeExpenseIndicator(
                            label: 'Income',
                            amount: widget.monthlyIncome,
                            icon: Icons.arrow_downward_rounded,
                            color: const Color(0xFF34D399),
                          ),
                        ),
                        Container(height: 36, width: 1, color: Colors.white.withValues(alpha: 0.2)),
                        Expanded(
                          child: _buildIncomeExpenseIndicator(
                            label: 'Expenses',
                            amount: widget.monthlyExpenses,
                            icon: Icons.arrow_upward_rounded,
                            color: const Color(0xFFF87171),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Action Buttons Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionButton(
                    context,
                    icon: Icons.add_rounded,
                    label: 'Add Tx',
                    color: theme.colorScheme.primary,
                    onTap: widget.onAddTransaction,
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.send_rounded,
                    label: 'Send',
                    color: theme.colorScheme.secondary,
                    onTap: widget.onQuickTransfer,
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Scan',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('QR Scanner initialized.')),
                      );
                    },
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.more_horiz_rounded,
                    label: 'More',
                    color: const Color(0xFFF59E0B),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Horizontal Payment Cards Carousel
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Accounts & Cards',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: widget.cards.length,
                    itemBuilder: (context, index) {
                      return PaymentCardItem(card: widget.cards[index]);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Recent Activity Header & Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_filteredTransactions.length} items',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Income', 'Expenses'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedFilter = filter),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide.none,
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transactions List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _filteredTransactions.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No transactions match this filter.')),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = _filteredTransactions[index];
                        return TransactionListTile(transaction: tx);
                      },
                      childCount: _filteredTransactions.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseIndicator({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. ANALYTICS & FINANCIAL PERFORMANCE SCREEN
// ============================================================================

class AnalyticsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final List<BudgetGoal> budgets;

  const AnalyticsScreen({super.key, required this.transactions, required this.budgets});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTimeframe = 0; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Flow Analytics',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track your spending and investment behavior over time',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),

            // Timeframe Segmented Control Button Row
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: ['Weekly', 'Monthly', 'Yearly'].asMap().entries.map((entry) {
                  final idx = entry.key;
                  final text = entry.value;
                  final isSelected = _selectedTimeframe == idx;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTimeframe = idx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.cardColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Custom Financial Line Chart Widget
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Spent',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const Text(
                              '\$4,820.50',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '↓ 8.5% vs last month',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: LineChartPainter(
                          lineColor: theme.colorScheme.primary,
                          fillGradientColors: [
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                          .map((day) => Text(
                                day,
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Budget Goals & Progress
            Text(
              'Monthly Budget Limits',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.budgets.map((b) => _buildBudgetCard(context, b)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, BudgetGoal goal) {
    final theme = Theme.of(context);
    final percentage = (goal.progress * 100).toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.category,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${goal.spent.toStringAsFixed(0)} spent of \$${goal.totalBudget.toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: goal.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: goal.color.withValues(alpha: 0.15),
                color: goal.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Financial Line Chart
class LineChartPainter extends CustomPainter {
  final Color lineColor;
  final List<Color> fillGradientColors;

  LineChartPainter({required this.lineColor, required this.fillGradientColors});

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.35, size.height * 0.8),
      Offset(size.width * 0.55, size.height * 0.3),
      Offset(size.width * 0.75, size.height * 0.45),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width, size.height * 0.25),
    ];

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    // Fill Gradient Path
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: fillGradientColors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line Paint
    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Draw active glowing data point
    final activePoint = points[points.length - 2];
    final outerPointPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final innerPointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(activePoint, 10, outerPointPaint);
    canvas.drawCircle(activePoint, 5, strokePaint);
    canvas.drawCircle(activePoint, 3, innerPointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// 3. WALLET & CARDS MANAGEMENT SCREEN
// ============================================================================

class WalletScreen extends StatelessWidget {
  final List<PaymentCard> cards;
  final List<Transaction> transactions;

  const WalletScreen({super.key, required this.cards, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Digital Wallet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage your connected cards & accounts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Card flow initiated.')),
                    );
                  },
                  icon: const Icon(Icons.add_card_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Stack List
            ...cards.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PaymentCardItem(card: c, isExpanded: true),
                )),

            const SizedBox(height: 16),
            Text(
              'Security & Controls',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: true,
                    onChanged: (val) {},
                    title: const Text('Contactless Payments'),
                    subtitle: const Text('NFC Tap & Pay enabled for VISA 4829'),
                    secondary: const Icon(Icons.contactless_rounded),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    value: false,
                    onChanged: (val) {},
                    title: const Text('Freeze Account'),
                    subtitle: const Text('Temporarily block all outgoing transactions'),
                    secondary: const Icon(Icons.lock_outline_rounded),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. SETTINGS & PROFILE SCREEN
// ============================================================================

class SettingsScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const SettingsScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account & Settings',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // User Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Text(
                        'AM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alex Morgan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'alex.morgan@novawealth.io',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // General Settings Group
            Text(
              'Preferences',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark Theme'),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) => onToggleTheme(),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.fingerprint_rounded),
                    title: const Text('Biometric Authentication'),
                    subtitle: const Text('Require FaceID / TouchID to open'),
                    trailing: Switch(
                      value: true,
                      onChanged: (val) {},
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.currency_exchange_rounded),
                    title: const Text('Default Currency'),
                    trailing: const Text('USD (\$)'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Security & Support
            Text(
              'System & Privacy',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Privacy & Security Policy'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: const Text('24/7 Priority Support'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// REUSABLE COMPONENTS & BOTTOM SHEETS
// ============================================================================

class PaymentCardItem extends StatelessWidget {
  final PaymentCard card;
  final bool isExpanded;

  const PaymentCardItem({super.key, required this.card, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? double.infinity : 280,
      margin: isExpanded ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: card.gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  card.cardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.contactless_rounded, color: Colors.white70, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            card.cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CARD HOLDER',
                      style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1),
                    ),
                    Text(
                      card.cardHolder,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1),
                  ),
                  Text(
                    card.expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionListTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: transaction.iconBgColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(transaction.icon, color: transaction.iconBgColor, size: 22),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${transaction.category} • ${_formatDate(transaction.date)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isIncome ? const Color(0xFF10B981) : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day) return 'Today';
    if (date.day == now.day - 1) return 'Yesterday';
    return '${date.month}/${date.day}';
  }
}

// Modal Bottom Sheet: Add New Transaction
class AddTransactionBottomSheet extends StatefulWidget {
  final Function(Transaction) onAddTransaction;

  const AddTransactionBottomSheet({super.key, required this.onAddTransaction});

  @override
  State<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'Electronics';

  final List<String> _categories = [
    'Electronics',
    'Groceries',
    'Transport',
    'Freelance Income',
    'Investments',
    'Entertainment'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid title and amount.')),
      );
      return;
    }

    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: _selectedCategory,
      amount: amount,
      date: DateTime.now(),
      icon: _selectedType == TransactionType.income
          ? Icons.arrow_downward_rounded
          : Icons.shopping_bag_rounded,
      iconBgColor: _selectedType == TransactionType.income
          ? const Color(0xFF10B981)
          : const Color(0xFF6366F1),
      type: _selectedType,
    );

    widget.onAddTransaction(newTx);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add New Transaction',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Segmented Button Type Selection
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                  ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (set) {
                  setState(() => _selectedType = set.first);
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title / Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.category_rounded),
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Transaction', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modal Bottom Sheet: Quick Money Transfer
class QuickTransferBottomSheet extends StatefulWidget {
  final Function(double amount, String recipient) onTransfer;

  const QuickTransferBottomSheet({super.key, required this.onTransfer});

  @override
  State<QuickTransferBottomSheet> createState() => _QuickTransferBottomSheetState();
}

class _QuickTransferBottomSheetState extends State<QuickTransferBottomSheet> {
  final _amountController = TextEditingController();
  int _selectedContactIndex = 0;

  final List<Map<String, String>> _contacts = [
    {'name': 'Sarah C.', 'avatar': 'SC'},
    {'name': 'David M.', 'avatar': 'DM'},
    {'name': 'Emma W.', 'avatar': 'EW'},
    {'name': 'James L.', 'avatar': 'JL'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _sendMoney() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid transfer amount.')),
      );
      return;
    }

    final recipient = _contacts[_selectedContactIndex]['name']!;
    widget.onTransfer(amount, recipient);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully sent \$$amount to $recipient!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quick Money Transfer',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text('Select Recipient:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  final isSelected = _selectedContactIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedContactIndex = index),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            child: Text(
                              contact['avatar']!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact['name']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount to Send (\$)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _sendMoney,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Confirm Transfer', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
