import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String filter = 'all';

  static const blue = Color(0xFF2463EB);
  static const background = Color(0xFFF6F7FB);

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final rows = await DatabaseHelper.instance.getTransactions();
      if (!mounted) return;
      setState(() {
        transactions = rows;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải giao dịch: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredTransactions {
    if (filter == 'income') {
      return transactions.where((t) => t['type'] == 'income').toList();
    }
    if (filter == 'expense') {
      return transactions.where((t) => t['type'] == 'expense').toList();
    }
    return transactions;
  }

  String money(dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0;
    final text = amount.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
    );
    return '$text đ';
  }

  Future<void> addTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (result == true) loadTransactions();
  }

  Future<void> editTransaction(Map<String, dynamic> transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: transaction),
      ),
    );
    if (result == true) loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final rows = filteredTransactions;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Tất cả giao dịch',
            style: TextStyle(color: Color(0xFF20243A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF20243A)),
      ),
      body: RefreshIndicator(
        onRefresh: loadTransactions,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: blue))
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  _filterButton('Tất cả', 'all'),
                  const SizedBox(width: 8),
                  _filterButton('Thu nhập', 'income'),
                  const SizedBox(width: 8),
                  _filterButton('Chi tiêu', 'expense'),
                ],
              ),
            ),
            Expanded(
              child: rows.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.receipt_long_rounded,
                      size: 58, color: Colors.blueGrey.shade200),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      filter == 'all'
                          ? 'Chưa có giao dịch nào'
                          : 'Không có giao dịch phù hợp',
                      style: const TextStyle(color: Color(0xFF777D90)),
                    ),
                  ),
                ],
              )
                  : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final t = rows[index];
                  final income = t['type'] == 'income';
                  final category = t['category']?.toString() ?? 'Khác';
                  final title = t['title']?.toString() ?? 'Giao dịch';
                  final date = t['date']?.toString() ?? '';
                  final amount = (t['amount'] as num?)?.toDouble() ?? 0;
                  final color = income
                      ? const Color(0xFF28A745)
                      : const Color(0xFFFF5B65);
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => editTransaction(t),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(.12),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                income
                                    ? Icons.south_west_rounded
                                    : Icons.north_east_rounded,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF20243A))),
                                  const SizedBox(height: 4),
                                  Text('$category • $date',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF777D90))),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${income ? '+' : '-'}${money(amount)}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTransaction,
        backgroundColor: blue,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: blue,
        unselectedItemColor: const Color(0xFF777D90),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline_rounded), label: 'Thống kê'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
          }
        },
      ),
    );
  }

  Widget _filterButton(String label, String value) {
    final selected = filter == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => filter = value),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? blue : Colors.white,
          foregroundColor: selected ? Colors.white : const Color(0xFF555B6E),
          side: BorderSide(color: selected ? blue : const Color(0xFFE4E7EF)),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
