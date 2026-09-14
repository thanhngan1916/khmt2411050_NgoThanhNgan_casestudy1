import 'package:flutter/material.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/edit_transaction_screen.dart';
import 'screens/home_screen.dart';
void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        fontFamily: 'Arial',
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              // Khoảng trống phía trên
              const SizedBox(height: 150),

              // ICON VÍ
              const WalletIcon(),

              const SizedBox(height: 22),

              // TIÊU ĐỀ
              const Text(
                'Expense Manager',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF12243A),
                ),
              ),

              const SizedBox(height: 16),

              // MÔ TẢ
              const Text(
                'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF7C8DA5),
                ),
              ),

              // Đẩy nút xuống dưới
              const Spacer(),

              // NÚT BẮT ĐẦU
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2375C8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }
}


/// ===============================
/// ICON VÍ TIỀN
/// ===============================

class WalletIcon extends StatelessWidget {
  const WalletIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 105,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Tờ tiền phía sau
          Positioned(
            top: 8,
            left: 48,
            child: Container(
              width: 70,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFF7BC67F),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),

          // Tờ tiền nhỏ phía sau
          Positioned(
            top: 18,
            left: 38,
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),

          // Thân ví
          Positioned(
            bottom: 5,
            left: 10,
            child: Container(
              width: 113,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF2375C8),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          // Phần khóa ví
          Positioned(
            bottom: 25,
            right: 7,
            child: Container(
              width: 44,
              height: 27,
              decoration: BoxDecoration(
                color: const Color(0xFF1559A8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}