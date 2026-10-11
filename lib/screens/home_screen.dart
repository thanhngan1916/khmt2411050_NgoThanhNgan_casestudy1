
import 'package:flutter/material.dart';

import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import '../database/database_helper.dart';
import 'transactions_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  bool isBalanceVisible = true;

  static const Color primaryBlue = Color(0xFF2463EB);
  static const Color backgroundColor = Color(0xFFF6F7FB);

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  // =========================
  // TẢI GIAO DỊCH TỪ SQLITE
  // =========================
  Future<void> loadTransactions() async {
    try {
      final data = await DatabaseHelper.instance.getTransactions();

      if (!mounted) return;

      setState(() {
        transactions = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải giao dịch: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải dữ liệu giao dịch'),
        ),
      );
    }
  }

  // =========================
  // TÍNH TỔNG THU NHẬP
  // =========================
  double get totalIncome {
    return transactions.fold<double>(0, (total, transaction) {
      if (transaction['type'] == 'income') {
        return total +
            ((transaction['amount'] as num?)?.toDouble() ?? 0);
      }
      return total;
    });
  }

  // =========================
  // TÍNH TỔNG CHI TIÊU
  // =========================
  double get totalExpense {
    return transactions.fold<double>(0, (total, transaction) {
      if (transaction['type'] == 'expense') {
        return total +
            ((transaction['amount'] as num?)?.toDouble() ?? 0);
      }
      return total;
    });
  }

  // =========================
  // TÍNH SỐ DƯ
  // =========================
  double get balance => totalIncome - totalExpense;

  // =========================
  // ĐỊNH DẠNG TIỀN VIỆT NAM
  // =========================
  String formatMoney(double amount) {
    final roundedAmount = amount.round();
    final formatted = roundedAmount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );

    return '$formatted đ';
  }

  // =========================
  // MỞ MÀN HÌNH THÊM GIAO DỊCH
  // =========================
  Future<void> openAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await loadTransactions();
    }
  }

  // =========================
  // MỞ MÀN HÌNH SỬA / XÓA
  // =========================
  Future<void> openEditTransaction(
      Map<String, dynamic> transaction,
      ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(
          transaction: transaction,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await loadTransactions();
    }
  }

  // =========================
  // CHỌN ICON THEO DANH MỤC
  // =========================
  IconData getCategoryIcon(String category, bool isIncome) {
    final value = category.toLowerCase();

    if (isIncome) {
      return Icons.account_balance_wallet_rounded;
    }

    if (value.contains('ăn') || value.contains('uong')) {
      return Icons.restaurant_rounded;
    }

    if (value.contains('xe') || value.contains('di chuy')) {
      return Icons.directions_car_rounded;
    }

    if (value.contains('mua sắm') || value.contains('mua sam')) {
      return Icons.shopping_cart_rounded;
    }

    if (value.contains('giáo dục') || value.contains('hoc')) {
      return Icons.school_rounded;
    }

    if (value.contains('nhà') || value.contains('dien')) {
      return Icons.home_rounded;
    }

    return Icons.receipt_long_rounded;
  }

  Color getCategoryColor(String category, bool isIncome) {
    if (isIncome) {
      return const Color(0xFF28A745);
    }

    final value = category.toLowerCase();

    if (value.contains('ăn') || value.contains('uong')) {
      return const Color(0xFFFF792E);
    }

    if (value.contains('xe') || value.contains('di chuy')) {
      return const Color(0xFF2693FF);
    }

    if (value.contains('mua sắm') || value.contains('mua sam')) {
      return const Color(0xFFAE47F5);
    }

    if (value.contains('giáo dục') || value.contains('hoc')) {
      return const Color(0xFF009F9A);
    }

    return const Color(0xFFFF5B65);
  }

  // =========================
  // GIAO DIỆN CHÍNH
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quản lý thu chi'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          icon: const Icon(
            Icons.menu_rounded,
            color: Color(0xFF20243A),
          ),
        ),
        title: const Text(
          'Quản lý thu chi',
          style: TextStyle(
            color: Color(0xFF20243A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bạn chưa có thông báo mới'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF20243A),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // BODY
      body: RefreshIndicator(
        onRefresh: loadTransactions,
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: primaryBlue,
          ),
        )
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // THẺ SỐ DƯ
              // =========================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4385F5),
                      Color(0xFF1557E8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'SỐ DƯ HIỆN TẠI',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isBalanceVisible =
                                    !isBalanceVisible;
                                  });
                                },
                                child: Icon(
                                  isBalanceVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              isBalanceVisible
                                  ? formatMoney(balance)
                                  : '••••••••',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.white,
                                size: 7,
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.circle,
                                color: Colors.white54,
                                size: 6,
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.circle,
                                color: Colors.white54,
                                size: 6,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFFFD166),
                      size: 66,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // TỔNG THU - TỔNG CHI
              // =========================
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'TỔNG THU NHẬP',
                      amount: totalIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: const Color(0xFF35B65A),
                      background: const Color(0xFFEAF7EC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      title: 'TỔNG CHI TIÊU',
                      amount: totalExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: const Color(0xFFFF5B65),
                      background: const Color(0xFFFFECEE),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================
              // TIÊU ĐỀ GIAO DỊCH
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20243A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =========================
              // DANH SÁCH GIAO DỊCH
              // =========================
              if (transactions.isEmpty)
                _buildEmptyState()
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEEF0F5),
                    ),
                  ),
                  child: Column(
                    children: transactions
                        .take(5)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final transaction = entry.value;

                      return Column(
                        children: [
                          _buildTransaction(transaction),
                          if (index < transactions.take(5).length - 1)
                            const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: Color(0xFFEEF0F5),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),

      // NÚT THÊM GIAO DỊCH
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTransaction,
        backgroundColor: primaryBlue,
        elevation: 5,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),

      // THANH ĐIỀU HƯỚNG
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: const Color(0xFF777D90),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 10,
        onTap: (index) {
          if (index == 0) {
            loadTransactions();
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransactionsScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StatisticsScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline_rounded),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }

  // =========================
  // THẺ TỔNG THU / TỔNG CHI
  // =========================
  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF74798B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // TRẠNG THÁI CHƯA CÓ GIAO DỊCH
  // =========================
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEF0F5),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 50,
            color: Color(0xFFB7BDCC),
          ),
          SizedBox(height: 12),
          Text(
            'Chưa có giao dịch nào',
            style: TextStyle(
              color: Color(0xFF74798B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Nhấn nút + để thêm giao dịch đầu tiên',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9AA0AF),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MỘT GIAO DỊCH
  // =========================
  Widget _buildTransaction(
      Map<String, dynamic> transaction,
      ) {
    final title = transaction['title']?.toString() ?? '';
    final category = transaction['category']?.toString() ?? '';
    final date = transaction['date']?.toString() ?? '';

    final amount =
        (transaction['amount'] as num?)?.toDouble() ?? 0;

    final isIncome = transaction['type'] == 'income';
    final icon = getCategoryIcon(category, isIncome);
    final color = getCategoryColor(category, isIncome);

    return InkWell(
      onTap: () => openEditTransaction(transaction),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        child: Row(
          children: [
            // ICON DANH MỤC
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            // THÔNG TIN GIAO DỊCH
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Giao dịch' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20243A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.isEmpty ? 'Chưa phân loại' : category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777D90),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date.isEmpty ? 'Chưa có ngày' : date,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9298A8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // SỐ TIỀN
            Flexible(
              child: Text(
                '${isIncome ? '+' : '-'}${formatMoney(amount)}',
                textAlign: TextAlign.end,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  color: isIncome
                      ? const Color(0xFF28A745)
                      : const Color(0xFFFF4D5A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
