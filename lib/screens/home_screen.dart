import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import '../database/database_helper.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();

    setState(() {
      transactions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // =========================
                    // HEADER
                    // =========================
                    Row(
                      children: [
                        const Icon(
                          Icons.menu,
                          size: 25,
                          color: Color(0xFF172033),
                        ),

                        const SizedBox(width: 20),

                        const Expanded(
                          child: Text(
                            'Quản lý thu chi',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),
                        ),

                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              size: 25,
                              color: Color(0xFF172033),
                            ),

                            Positioned(
                              right: -3,
                              top: -5,
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // =========================
                    // SỐ DƯ HIỆN TẠI
                    // =========================
                    Container(
                      width: double.infinity,
                      height: 126,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4B86F5),
                            Color(0xFF1260E9),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [

                          Padding(
                            padding: const EdgeInsets.only(
                              top: 25,
                              left: 20,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'SỐ DƯ HIỆN TẠI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    const SizedBox(width: 7),

                                    const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 7),

                                const Text(
                                  '5.000.000 đ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Hình ví đơn giản
                          Positioned(
                            right: 17,
                            top: 22,
                            child: _WalletIcon(),
                          ),

                          // Dấu chấm slider
                          Positioned(
                            bottom: 6,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                _dot(true),
                                _dot(false),
                                _dot(false),
                                _dot(false),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // THU NHẬP + CHI TIÊU
                    // =========================
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            icon: Icons.arrow_downward,
                            title: 'TỔNG THU NHẬP',
                            amount: '8.000.000 đ',
                            iconColor: const Color(0xFF55B867),
                            backgroundColor:
                            const Color(0xFFEAF8EC),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: _summaryCard(
                            icon: Icons.arrow_upward,
                            title: 'TỔNG CHI TIÊU',
                            amount: '3.000.000 đ',
                            iconColor: const Color(0xFFFF5C63),
                            backgroundColor:
                            const Color(0xFFFFEEEE),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // =========================
                    // GIAO DỊCH GẦN ĐÂY
                    // =========================
                    Row(
                      children: [
                        const Text(
                          'Giao dịch gần đây',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),

                        const Spacer(),

                        const Text(
                          'Xem tất cả',
                          style: TextStyle(
                            color: Color(0xFF1761E8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    ...transactions.take(5).map((transaction) {
                      final isIncome = transaction['type'] == 'Thu';

                      return _transactionItem(
                        icon: isIncome
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        iconColor: isIncome
                            ? const Color(0xFF39A952)
                            : const Color(0xFFFF5C63),
                        title: transaction['title'] ?? '',
                        category: transaction['category'] ?? '',
                        date: transaction['date'] ?? '',
                        amount: '${isIncome ? '+' : '-'}${transaction['amount']} đ',
                        amountColor: isIncome
                            ? const Color(0xFF1DA342)
                            : Colors.red,
                      );
                    }).toList(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // =========================
            // BOTTOM NAVIGATION
            // =========================
            Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: [
                  _bottomItem(
                    icon: Icons.home,
                    title: 'Trang chủ',
                    active: true,
                  ),

                  _bottomItem(
                    icon: Icons.receipt_long,
                    title: 'Giao dịch',
                    active: false,
                  ),

                  _bottomItem(
                    icon: Icons.pie_chart_outline,
                    title: 'Thống kê',
                    active: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // =========================
      // NÚT +
      // =========================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1761E8),
        elevation: 4,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const AddTransactionScreen(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
    );
  }

  // ==========================================
  // CARD TỔNG THU / TỔNG CHI
  // ==========================================

  static Widget _summaryCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF777777),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GIAO DỊCH
  // ==========================================

  static Widget _transactionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String category,
    required String date,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEDEDED),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 17,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2638),
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF777777),
                      ),
                    ),

                    const SizedBox(width: 18),

                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF9AA0AA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM MENU
  // ==========================================

  static Widget _bottomItem({
    required IconData icon,
    required String title,
    required bool active,
  }) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 21,
          color: active
              ? const Color(0xFF1761E8)
              : const Color(0xFF333333),
        ),

        const SizedBox(height: 3),

        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: active
                ? FontWeight.bold
                : FontWeight.normal,
            color: active
                ? const Color(0xFF1761E8)
                : const Color(0xFF555555),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CHẤM SLIDER
  // ==========================================

  static Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: active ? 12 : 5,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}


// ==========================================
// ICON VÍ TIỀN
// ==========================================

class _WalletIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 70,
      child: Stack(
        children: [
          // Tiền
          Positioned(
            top: 0,
            right: 8,
            child: Container(
              width: 38,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF70C97A),
                borderRadius:
                BorderRadius.circular(3),
              ),
            ),
          ),

          // Ví
          Positioned(
            left: 4,
            bottom: 8,
            child: Container(
              width: 55,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1559B0),
                borderRadius:
                BorderRadius.circular(8),
              ),
            ),
          ),

          // Khóa ví
          Positioned(
            right: 2,
            bottom: 19,
            child: Container(
              width: 25,
              height: 17,
              decoration: BoxDecoration(
                color: const Color(0xFF0F4389),
                borderRadius:
                BorderRadius.circular(5),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 3,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),

          // Đồng xu
          Positioned(
            left: 2,
            bottom: 0,
            child: Container(
              width: 21,
              height: 21,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB51B),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '₫',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}