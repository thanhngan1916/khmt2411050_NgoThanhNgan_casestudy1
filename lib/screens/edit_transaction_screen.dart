import 'package:flutter/material.dart';
import '../database/database_helper.dart';
class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key});

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {

  bool isExpense = true;
  String category = 'Ăn uống';

  final amountController =
  TextEditingController(text: '100.000');

  final noteController =
  TextEditingController(text: 'Ăn trưa');

  DateTime selectedDate = DateTime(2025, 4, 12);

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Sửa giao dịch',
          style: TextStyle(
            color: Color(0xFF12243A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 8),

            // CHI TIÊU / THU NHẬP
            Row(
              children: [

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpense = true;
                      });
                    },

                    child: Container(
                      height: 36,

                      decoration: BoxDecoration(
                        color: isExpense
                            ? const Color(0xFFFF5A63)
                            : Colors.white,

                        borderRadius:
                        BorderRadius.circular(7),

                        border: Border.all(
                          color: const Color(0xFFE0E4EA),
                        ),
                      ),

                      alignment: Alignment.center,

                      child: Text(
                        'Chi tiêu',

                        style: TextStyle(
                          color: isExpense
                              ? Colors.white
                              : const Color(0xFF12243A),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpense = false;
                      });
                    },

                    child: Container(
                      height: 36,

                      decoration: BoxDecoration(
                        color: !isExpense
                            ? const Color(0xFFFF5A63)
                            : Colors.white,

                        borderRadius:
                        BorderRadius.circular(7),

                        border: Border.all(
                          color: const Color(0xFFE0E4EA),
                        ),
                      ),

                      alignment: Alignment.center,

                      child: Text(
                        'Thu nhập',

                        style: TextStyle(
                          color: !isExpense
                              ? Colors.white
                              : const Color(0xFF12243A),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // DANH MỤC
            const Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12243A),
              ),
            ),

            const SizedBox(height: 7),

            Container(
              height: 48,

              padding:
              const EdgeInsets.symmetric(horizontal: 10),

              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFDDE2E8),
                ),

                borderRadius:
                BorderRadius.circular(8),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: category,
                  isExpanded: true,

                  items: const [

                    DropdownMenuItem(
                      value: 'Ăn uống',

                      child: Row(
                        children: [

                          CircleAvatar(
                            radius: 12,

                            backgroundColor:
                            Color(0xFFFF6870),

                            child: Icon(
                              Icons.restaurant,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 10),

                          Text('Ăn uống'),
                        ],
                      ),
                    ),

                    DropdownMenuItem(
                      value: 'Mua sắm',
                      child: Text('Mua sắm'),
                    ),

                    DropdownMenuItem(
                      value: 'Di chuyển',
                      child: Text('Di chuyển'),
                    ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      category = value!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SỐ TIỀN
            const Text(
              'Số tiền',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12243A),
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller: amountController,

              keyboardType:
              TextInputType.number,

              decoration: InputDecoration(
                suffixText: 'đ',

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                ),

                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),

                  borderSide:
                  const BorderSide(
                    color: Color(0xFFDDE2E8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // NGÀY
            const Text(
              'Ngày giao dịch',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12243A),
              ),
            ),

            const SizedBox(height: 7),

            GestureDetector(
              onTap: selectDate,

              child: Container(
                height: 48,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDDE2E8),
                  ),

                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: Row(
                  children: [

                    Expanded(
                      child: Text(
                        formatDate(selectedDate),
                      ),
                    ),

                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // GHI CHÚ
            const Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12243A),
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller: noteController,
              maxLines: 3,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                ),

                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),

                  borderSide:
                  const BorderSide(
                    color: Color(0xFFDDE2E8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // LƯU
            SizedBox(
              width: double.infinity,
              height: 48,

              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2375C8),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                ),

                child: const Text(
                  'Lưu',

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}