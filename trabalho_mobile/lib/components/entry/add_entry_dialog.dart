import 'package:flutter/material.dart';
import 'package:trabalho_mobile/models/entry.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:trabalho_mobile/utils/app_colors.dart';
import 'package:trabalho_mobile/utils/app_icons.dart';

class IconOption {
  final String id;
  final String label;
  IconOption(this.id, this.label);
}

class AddEntryDialog extends StatefulWidget {
  final Box<Entry> entriesBox;
  final Entry? entryToEdit;
  final int? entryIndex;

  const AddEntryDialog({
    super.key,
    required this.entriesBox,
    this.entryToEdit,
    this.entryIndex,
  });

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? selectedDate;
  int _sign = 1;

  final List<IconOption> icons = [
    IconOption(AppIcons.entrada, "Entrada"),
    IconOption(AppIcons.investimentoId, 'Investimento'),
    IconOption(AppIcons.alimentacaoId, 'Alimentação'),
    IconOption(AppIcons.cartaoId, 'Cartão'),
    IconOption(AppIcons.contasId, 'Contas'),
    IconOption(AppIcons.comprasId, 'Compras'),
  ];

  late final PageController _pageController;
  late int _selectedIndex;
  final NumberFormat _amountFormat = NumberFormat.currency(
    locale: 'pt_BR', symbol: '', decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
   
    if (widget.entryToEdit != null && widget.entryIndex != null) {
      final e = widget.entryToEdit!;
      _titleController.text = e.title;
      _descriptionController.text = e.description;
      _sign = e.amount >= 0 ? 1 : -1;
      selectedDate = e.date;
      _selectedIndex = icons.indexWhere((opt) => opt.id == e.iconId);
      if (_selectedIndex < 0) _selectedIndex = icons.length ~/ 2;
      
      final absValue = e.amount.abs();
      _amountController.text = _amountFormat.format(absValue);
    } else {
      
      _selectedIndex = icons.length ~/ 2;
      selectedDate = DateTime.now();
    }
    _pageController = PageController(
      initialPage: _selectedIndex,
      viewportFraction: 0.3,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _toggleSign() => setState(() => _sign = -_sign);

  void _save() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
 
    final digitsOnly = _amountController.text.replaceAll(RegExp(r'\D'), '');
    final raw = double.tryParse(digitsOnly) ?? 0.0;
    final amount = (raw / 100) * _sign;

    if (title.isEmpty || digitsOnly.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título e Valor são obrigatórios.')),
      );
      return;
    }

    final selectedId = icons[_selectedIndex].id;
    final newEntry = Entry(
      title: title,
      description: description,
      amount: amount,
      date: selectedDate ?? DateTime.now(),
      iconId: selectedId,
    );

    if (widget.entryToEdit != null && widget.entryIndex != null) {
      widget.entriesBox.putAt(widget.entryIndex!, newEntry);
    } else {
      widget.entriesBox.add(newEntry);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.entryToEdit != null ? 'Editar Lançamento' : 'Novo Lançamento',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildTextField(_titleController, 'Título'),
                const SizedBox(height: 10),
                
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [MoneyInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: IconButton(
                      icon: Text(
                        _sign > 0 ? '+' : '-',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _toggleSign,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(_descriptionController, 'Descrição'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? 'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}'
                            : 'Data: Hoje',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Ícone'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: icons.length,
                    onPageChanged: (idx) => setState(() => _selectedIndex = idx),
                    itemBuilder: (ctx, i) {
                      final iconOpt = icons[i];
                      final isSel = _selectedIndex == i;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isSel
                                    ? Border.all(color: AppColors.primary, width: 2)
                                    : null,
                              ),
                              child: Image.network(
                                AppIcons.getUrlById(iconOpt.id),
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            iconOpt.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? AppColors.primary : Colors.black87,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _save,
                      child: const Text(
                        'Salvar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class MoneyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR', symbol: '', decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return oldValue;
    final value = double.parse(digits) / 100;
    final newText = _formatter.format(value);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
