
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  bool isExpense = true;
  bool isSaving = false;
  String category = 'Ăn uống';
  DateTime selectedDate = DateTime.now();

  static const Color primaryBlue = Color(0xFF2375ED);
  static const Color expenseRed = Color(0xFFFF626B);
  static const Color incomeGreen = Color(0xFF2EAD62);
  static const Color textColor = Color(0xFF172943);
  static const Color borderColor = Color(0xFFDCE3EC);
  static const Color backgroundColor = Color(0xFFF8FAFD);
  static const Color hintColor = Color(0xFF8290A3);

  List<String> get categories {
    return isExpense
        ? ['Ăn uống', 'Mua sắm', 'Di chuyển', 'Giáo dục', 'Khác']
        : ['Thu nhập'];
  }

  String get formattedDate => formatDate(selectedDate);

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  // =========================
  // KHỞI TẠO DỮ LIỆU CŨ
  // =========================
  void _loadTransactionData() {
    final transaction = widget.transaction;

    titleController.text = transaction['title']?.toString() ?? '';
    noteController.text = transaction['note']?.toString() ?? '';

    final savedAmount = transaction['amount'];
    if (savedAmount != null) {
      final amount = double.tryParse(savedAmount.toString());
      amountController.text = amount == null
          ? savedAmount.toString()
          : amount.toStringAsFixed(
        amount == amount.truncateToDouble() ? 0 : 2,
      );
    }

    isExpense = transaction['type'] == 'expense';

    final savedCategory = transaction['category']?.toString() ?? '';
    category = categories.contains(savedCategory)
        ? savedCategory
        : (isExpense ? 'Ăn uống' : 'Thu nhập');

    final savedDate = transaction['date']?.toString() ?? '';
    selectedDate = _parseDate(savedDate);
  }

  // Hỗ trợ cả dd/MM/yyyy và yyyy-MM-dd
  DateTime _parseDate(String value) {
    if (value.isEmpty) return DateTime.now();

    try {
      final parts = value.split('/');

      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }

      return DateTime.parse(value);
    } catch (_) {
      return DateTime.now();
    }
  }

  // =========================
  // THÔNG BÁO
  // =========================
  void _showMessage(String message) {
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
  // CHUYỂN LOẠI THU / CHI
  // =========================
  void _changeType(bool expense) {
    setState(() {
      isExpense = expense;
      category = expense ? 'Ăn uống' : 'Thu nhập';
    });
  }

  // =========================
  // CHỌN NGÀY GIAO DỊCH
  // =========================
  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  // =========================
  // CHUYỂN SỐ TIỀN THÀNH SỐ
  // Ví dụ: 50.000 -> 50000
  // =========================
  double? _parseAmount(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '');

    return double.tryParse(normalized);
  }

  // =========================
  // CẬP NHẬT GIAO DỊCH
  // =========================
  Future<void> updateTransaction() async {
    if (isSaving) return;

    final title = titleController.text.trim();
    final amountText = amountController.text.trim();

    if (title.isEmpty) {
      _showMessage('Vui lòng nhập tên giao dịch');
      return;
    }

    if (amountText.isEmpty) {
      _showMessage('Vui lòng nhập số tiền');
      return;
    }

    final amount = _parseAmount(amountText);

    if (amount == null || !amount.isFinite || amount <= 0) {
      _showMessage('Số tiền không hợp lệ');
      return;
    }

    final id = widget.transaction['id'];

    if (id == null) {
      _showMessage('Không tìm thấy mã giao dịch');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });

    try {
      final result = await DatabaseHelper.instance.updateTransaction(
        id as int,
        {
          'title': title,
          'amount': amount,
          'type': isExpense ? 'expense' : 'income',
          'category': category,
          'date': formattedDate,
          'note': noteController.text.trim(),
        },
      );

      if (!mounted) return;

      if (result > 0) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          isSaving = false;
        });
        _showMessage('Không tìm thấy giao dịch để cập nhật');
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật giao dịch: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      _showMessage('Cập nhật thất bại. Vui lòng thử lại');
    }
  }

  // =========================
  // XÓA GIAO DỊCH
  // =========================
  Future<void> deleteTransaction() async {
    if (isSaving) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xóa giao dịch',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn xóa giao dịch này không? '
                'Dữ liệu đã xóa sẽ không thể khôi phục.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: expenseRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final id = widget.transaction['id'];

    if (id == null) {
      _showMessage('Không tìm thấy mã giao dịch');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final result = await DatabaseHelper.instance.deleteTransaction(
        id as int,
      );

      if (!mounted) return;

      if (result > 0) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          isSaving = false;
        });
        _showMessage('Không tìm thấy giao dịch để xóa');
      }
    } catch (e) {
      debugPrint('Lỗi xóa giao dịch: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      _showMessage('Xóa giao dịch thất bại. Vui lòng thử lại');
    }
  }

  // =========================
  // GIAO DIỆN Ô NHẬP
  // =========================
  InputDecoration inputDecoration({
    String? hintText,
    String? suffixText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF98A3B3),
        fontSize: 12,
      ),
      suffixStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 13,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.3,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
    );
  }

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // =========================
  // NÚT CHỌN THU / CHI
  // =========================
  Widget _typeButton({
    required String title,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isSaving ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String value) {
    switch (value) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Mua sắm':
        return Icons.shopping_bag;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Giáo dục':
        return Icons.school;
      case 'Thu nhập':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    final activeColor = isExpense ? expenseRed : incomeGreen;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: textColor,
            size: 21,
          ),
        ),
        title: const Text(
          'Sửa giao dịch',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isSaving ? null : deleteTransaction,
            tooltip: 'Xóa giao dịch',
            icon: const Icon(
              Icons.delete_outline,
              color: expenseRed,
              size: 22,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF243A5E).withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOẠI GIAO DỊCH
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _typeButton(
                        title: 'Chi tiêu',
                        selected: isExpense,
                        selectedColor: expenseRed,
                        onTap: () => _changeType(true),
                      ),
                      const SizedBox(width: 4),
                      _typeButton(
                        title: 'Thu nhập',
                        selected: !isExpense,
                        selectedColor: incomeGreen,
                        onTap: () => _changeType(false),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // TÊN GIAO DỊCH
                fieldLabel('Tên giao dịch'),
                TextField(
                  controller: titleController,
                  enabled: !isSaving,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textColor,
                  ),
                  decoration: inputDecoration(
                    hintText: 'Nhập tên giao dịch',
                  ),
                ),

                const SizedBox(height: 16),

                // DANH MỤC
                fieldLabel('Danh mục'),
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: categories.contains(category) ? category : null,
                      hint: const Text(
                        'Chọn danh mục',
                        style: TextStyle(fontSize: 12),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: hintColor,
                      ),
                      items: categories.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Row(
                            children: [
                              Icon(
                                _categoryIcon(item),
                                color: activeColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                            ],
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
                  ),
                ),

                const SizedBox(height: 16),

                // SỐ TIỀN
                fieldLabel('Số tiền'),
                TextField(
                  controller: amountController,
                  enabled: !isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: inputDecoration(
                    hintText: 'Nhập số tiền',
                    suffixText: 'đ',
                  ),
                ),

                const SizedBox(height: 16),

                // NGÀY GIAO DỊCH
                fieldLabel('Ngày giao dịch'),
                InkWell(
                  onTap: isSaving ? null : selectDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                          color: hintColor,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // GHI CHÚ
                fieldLabel('Ghi chú'),
                TextField(
                  controller: noteController,
                  enabled: !isSaving,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                  decoration: inputDecoration(
                    hintText: 'Nhập ghi chú (tùy chọn)',
                  ),
                ),

                const SizedBox(height: 22),

                // NÚT LƯU
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : updateTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor:
                      primaryBlue.withOpacity(0.6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Lưu thay đổi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
