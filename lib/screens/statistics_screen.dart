import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // =========================
  // DỮ LIỆU
  // =========================

  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];

  String selectedFilter = 'Tất cả';

  // =========================
  // KHỞI TẠO
  // =========================

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  // =========================
  // LẤY DỮ LIỆU SQLITE
  // =========================

  Future<void> loadTransactions() async {
    try {
      final data = await DatabaseHelper.instance.getTransactions();

      if (!mounted) return;

      setState(() {
        transactions = data;
      });

      applyFilter(selectedFilter);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải dữ liệu: $e'),
        ),
      );
    }
  }

  // =========================
  // LỌC DỮ LIỆU
  // =========================

  void applyFilter(String filter) {
    final now = DateTime.now();

    List<Map<String, dynamic>> result = [];

    // TẤT CẢ
    if (filter == 'Tất cả') {
      result = List<Map<String, dynamic>>.from(transactions);
    }

    // HÔM NAY
    else if (filter == 'Hôm nay') {
      result = transactions.where((transaction) {
        final date = parseDate(
          transaction['date']?.toString() ?? '',
        );

        if (date == null) return false;

        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }).toList();
    }

    // 7 NGÀY GẦN ĐÂY
    else if (filter == '7 ngày gần đây') {
      final startDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        const Duration(days: 6),
      );

      final endDate = DateTime(
        now.year,
        now.month,
        now.day,
      );

      result = transactions.where((transaction) {
        final date = parseDate(
          transaction['date']?.toString() ?? '',
        );

        if (date == null) return false;

        final transactionDate = DateTime(
          date.year,
          date.month,
          date.day,
        );

        return !transactionDate.isBefore(startDate) &&
            !transactionDate.isAfter(endDate);
      }).toList();
    }

    // THÁNG NÀY
    else if (filter == 'Tháng này') {
      result = transactions.where((transaction) {
        final date = parseDate(
          transaction['date']?.toString() ?? '',
        );

        if (date == null) return false;

        return date.year == now.year &&
            date.month == now.month;
      }).toList();
    }

    if (!mounted) return;

    setState(() {
      selectedFilter = filter;
      filteredTransactions = result;
    });
  }

  // =========================
  // CHUYỂN NGÀY
  // dd/MM/yyyy -> DateTime
  // =========================

  DateTime? parseDate(String value) {
    try {
      final parts = value.split('/');

      if (parts.length != 3) {
        return null;
      }

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(
        year,
        month,
        day,
      );
    } catch (e) {
      return null;
    }
  }

  // =========================
  // TỔNG THU
  // =========================

  double get totalIncome {
    double total = 0;

    for (final transaction in filteredTransactions) {
      if (transaction['type'] == 'income') {
        final amount = transaction['amount'];

        if (amount is num) {
          total += amount.toDouble();
        }
      }
    }

    return total;
  }

  // =========================
  // TỔNG CHI
  // =========================

  double get totalExpense {
    double total = 0;

    for (final transaction in filteredTransactions) {
      if (transaction['type'] == 'expense') {
        final amount = transaction['amount'];

        if (amount is num) {
          total += amount.toDouble();
        }
      }
    }

    return total;
  }

  // =========================
  // SỐ DƯ
  // =========================

  double get balance {
    return totalIncome - totalExpense;
  }

  // =========================
  // CHI THEO DANH MỤC
  // =========================

  double expenseByCategory(String category) {
    double total = 0;

    for (final transaction in filteredTransactions) {
      if (transaction['type'] == 'expense' &&
          transaction['category'] == category) {
        final amount = transaction['amount'];

        if (amount is num) {
          total += amount.toDouble();
        }
      }
    }

    return total;
  }

  // =========================
  // FORMAT TIỀN
  // =========================

  String formatMoney(double amount) {
    return '${amount
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    )} đ';
  }

  // =========================
  // MENU BỘ LỌC
  // =========================

  void showFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chọn khoảng thời gian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12243A),
                  ),
                ),

                const SizedBox(height: 15),

                _filterOption('Tất cả'),

                _filterOption('Hôm nay'),

                _filterOption('7 ngày gần đây'),

                _filterOption('Tháng này'),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // MỘT LỰA CHỌN BỘ LỌC
  // =========================

  Widget _filterOption(String value) {
    final bool selected = selectedFilter == value;

    return ListTile(
      leading: Icon(
        value == 'Tất cả'
            ? Icons.all_inclusive
            : value == 'Hôm nay'
            ? Icons.today
            : value == '7 ngày gần đây'
            ? Icons.date_range
            : Icons.calendar_month,
        color: const Color(0xFF2375C8),
      ),
      title: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
      trailing: selected
          ? const Icon(
        Icons.check,
        color: Color(0xFF2375C8),
      )
          : null,
      onTap: () {
        Navigator.pop(context);
        applyFilter(value);
      },
    );
  }

  // =========================
  // GIAO DIỆN
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // =========================
      // APP BAR
      // =========================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Thống kê',
          style: TextStyle(
            color: Color(0xFF12243A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =========================
      // BODY
      // =========================

      body: RefreshIndicator(
        onRefresh: loadTransactions,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // BỘ LỌC
              // =========================

              GestureDetector(
                onTap: showFilterMenu,

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: const Color(0xFFDDE2E8),
                    ),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF2375C8),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Khoảng thời gian',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              selectedFilter,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF12243A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // SỐ DƯ
              // =========================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFF2375C8),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số dư',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      formatMoney(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // TỔNG THU / TỔNG CHI
              // =========================

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'Tổng thu',
                      amount: totalIncome,
                      icon: Icons.arrow_downward,
                      iconColor: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _summaryCard(
                      title: 'Tổng chi',
                      amount: totalExpense,
                      icon: Icons.arrow_upward,
                      iconColor: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================
              // CHI THEO DANH MỤC
              // =========================

              const Text(
                'Chi tiêu theo danh mục',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF12243A),
                ),
              ),

              const SizedBox(height: 12),

              _categoryItem(
                'Ăn uống',
                expenseByCategory('Ăn uống'),
                Icons.restaurant,
              ),

              _categoryItem(
                'Mua sắm',
                expenseByCategory('Mua sắm'),
                Icons.shopping_bag,
              ),

              _categoryItem(
                'Di chuyển',
                expenseByCategory('Di chuyển'),
                Icons.directions_car,
              ),

              const SizedBox(height: 10),

              // =========================
              // SỐ GIAO DỊCH
              // =========================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF2375C8),
                      size: 30,
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'Số giao dịch',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      '${filteredTransactions.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2375C8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // CARD TỔNG THU / CHI
  // =========================

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 22,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12243A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // CARD DANH MỤC
  // =========================

  Widget _categoryItem(
      String category,
      double amount,
      IconData icon,
      ) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFFFF6870)
                  .withOpacity(0.12),

              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: const Color(0xFFFF6870),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12243A),
              ),
            ),
          ),

          Text(
            formatMoney(amount),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}