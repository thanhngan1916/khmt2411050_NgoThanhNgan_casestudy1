
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  bool isExpense = true;
  bool isSaving = false;

  String category = 'Ăn uống';
  DateTime selectedDate = DateTime.now();

  static const Color primaryBlue = Color(0xFF2475ED);
  static const Color expenseRed = Color(0xFFFF626C);
  static const Color incomeGreen = Color(0xFF2EAD62);
  static const Color textColor = Color(0xFF26344D);
  static const Color borderColor = Color(0xFFDCE3ED);
  static const Color hintColor = Color(0xFF8290A5);

  List<String> get categories {
    return isExpense
        ? ['Ăn uống', 'Di chuyển', 'Mua sắm', 'Giáo dục', 'Khác']
        : ['Thu nhập'];
  }

  String get formattedDate {
    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  // =========================
  // THÔNG BÁO
  // =========================
  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =========================
  // LƯU GIAO DỊCH VÀO SQLITE
  // =========================
  Future<void> saveTransaction() async {
    if (isSaving) return;

    final title = titleController.text.trim();
    final amountText = amountController.text
        .trim()
        .replaceAll(',', '')
        .replaceAll('.', '');

    if (title.isEmpty) {
      showMessage('Vui lòng nhập tên giao dịch');
      return;
    }

    if (amountController.text.trim().isEmpty) {
      showMessage('Vui lòng nhập số tiền');
      return;
    }

    // Hỗ trợ nhập số tiền nguyên có dấu phân cách.
    final amount = double.tryParse(amountText);

    if (amount == null || !amount.isFinite || amount <= 0) {
      showMessage('Số tiền không hợp lệ');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });

    try {
      await DatabaseHelper.instance.insertTransaction({
        'title': title,
        'amount': amount,
        'type': isExpense ? 'expense' : 'income',
        'category': category,
        'date': formattedDate,
        'note': noteController.text.trim(),
      });

      if (!mounted) return;

      // Báo Dashboard tải lại dữ liệu SQLite.
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Lỗi lưu giao dịch: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage('Lưu giao dịch thất bại. Vui lòng thử lại.');
    }
  }

  // =========================
  // CHỌN NGÀY
  // =========================
  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // =========================
  // CHUYỂN LOẠI GIAO DỊCH
  // =========================
  void changeTransactionType(bool expense) {
    setState(() {
      isExpense = expense;
      category = expense ? 'Ăn uống' : 'Thu nhập';
    });
  }

  // =========================
  // INPUT DECORATION
  // =========================
  InputDecoration inputDecoration({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: hintColor,
        fontSize: 13,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.3,
        ),
      ),
    );
  }

  // =========================
  // NHÃN TRƯỜNG
  // =========================
  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================
  // NÚT CHỌN THU / CHI
  // =========================
  Widget buildTypeButton({
    required String title,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? selectedColor : borderColor,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // GIAO DIỆN
  // =========================
  @override
  Widget build(BuildContext context) {
    final activeColor = isExpense ? expenseRed : incomeGreen;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFBFD),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: textColor,
          ),
          onPressed: isSaving
              ? null
              : () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm giao dịch',
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF243A5E)
                      .withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOẠI GIAO DỊCH
                Row(
                  children: [
                    buildTypeButton(
                      title: 'Chi tiêu',
                      selected: isExpense,
                      selectedColor: expenseRed,
                      onTap: () => changeTransactionType(true),
                    ),
                    const SizedBox(width: 10),
                    buildTypeButton(
                      title: 'Thu nhập',
                      selected: !isExpense,
                      selectedColor: incomeGreen,
                      onTap: () => changeTransactionType(false),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // DANH MỤC
                fieldLabel('Danh mục'),
                DropdownButtonFormField<String>(
                  value: category,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: hintColor,
                  ),
                  decoration: inputDecoration(
                    prefixIcon: Icon(
                      isExpense
                          ? Icons.category_outlined
                          : Icons.account_balance_wallet_outlined,
                      color: activeColor,
                      size: 19,
                    ),
                  ),
                  items: categories.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: isSaving
                      ? null
                      : (value) {
                    if (value != null) {
                      setState(() {
                        category = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                // TÊN GIAO DỊCH
                fieldLabel('Tên giao dịch'),
                TextField(
                  controller: titleController,
                  enabled: !isSaving,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                  ),
                  decoration: inputDecoration(
                    hint: 'Nhập tên giao dịch',
                  ),
                ),

                const SizedBox(height: 18),

                // SỐ TIỀN
                fieldLabel('Số tiền'),
                TextField(
                  controller: amountController,
                  enabled: !isSaving,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: inputDecoration(
                    hint: 'Nhập số tiền',
                    suffixText: 'đ',
                  ),
                ),

                const SizedBox(height: 18),

                // NGÀY GIAO DỊCH
                fieldLabel('Ngày giao dịch'),
                InkWell(
                  onTap: isSaving ? null : selectDate,
                  borderRadius: BorderRadius.circular(9),
                  child: InputDecorator(
                    decoration: inputDecoration(
                      suffixIcon: const Icon(
                        Icons.calendar_month_outlined,
                        color: hintColor,
                        size: 19,
                      ),
                    ),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // GHI CHÚ
                fieldLabel('Ghi chú'),
                TextField(
                  controller: noteController,
                  enabled: !isSaving,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                  ),
                  decoration: inputDecoration(
                    hint: 'Nhập ghi chú (tùy chọn)',
                  ),
                ),

                const SizedBox(height: 24),

                // NÚT LƯU
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor:
                      primaryBlue.withOpacity(0.6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Lưu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
