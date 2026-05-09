import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../domain/entities/cart_item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  Category _selectedCategory = Category.food;
  bool _isScanning = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _subcategoryController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final item = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      quantity: 1,
      subcategory: _emptyToNull(_subcategoryController.text),
      price: _parsePrice(_priceController.text),
      description: _emptyToNull(_descriptionController.text),
    );

    context.read<CartBloc>().add(CartItemAdded(item));
    context.go('/feed');
  }

  void _onScan() {
    setState(() => _isScanning = true);
  }

  void _onQrDetected(BarcodeCapture capture) {
    final String? code = capture.barcodes.first.rawValue;
    if (code == null) return;

    // Parse QR code and fill fields
    if (code.startsWith('food')) {
      _selectedCategory = Category.food;
      _categoryController.text = 'Еда';
    } else if (code.startsWith('beauty')) {
      _selectedCategory = Category.beauty;
      _categoryController.text = 'Бьюти';
    }

    final parts = code.split('/');
    if (parts.length >= 5) {
      _subcategoryController.text = parts[1];
      _nameController.text = parts[2];
      _priceController.text = parts[3];
      _descriptionController.text = parts.sublist(4).join('/');
    } else {
      // Extract name from QR code (after prefix)
      final name = code.replaceFirst(RegExp(r'^(food|beauty)'), '');
      _nameController.text = name.isNotEmpty ? name : '';
    }

    setState(() => _isScanning = false);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int? _parsePrice(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  @override
  Widget build(BuildContext context) {
    if (_isScanning) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Сканировать QR'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _isScanning = false),
          ),
        ),
        body: MobileScanner(onDetect: _onQrDetected),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F5),
        elevation: 0,
        title: const Text(
          'Добавить',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/feed'),
        ),
        actions: [
          TextButton(
            onPressed: _onScan,
            child: const Text(
              'Сканировать',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Category dropdown
                    _buildDropdownField(
                      label: 'Категория',
                      value: _selectedCategory == Category.food
                          ? 'Еда'
                          : 'Бьюти',
                      items: const ['Еда', 'Бьюти'],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value == 'Еда'
                              ? Category.food
                              : Category.beauty;
                          _categoryController.text = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subcategory field
                    _buildTextField(
                      controller: _subcategoryController,
                      label: 'Подкатегория',
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Название',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Введите название'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Price field
                    _buildTextField(
                      controller: _priceController,
                      label: 'Цена',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Description label
                    const Text(
                      'Описание',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),

                    // Description field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF62C5B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Wavy bottom
          CustomPaint(
            size: const Size(double.infinity, 40),
            painter: _WavyBottomPainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey.shade600),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _WavyBottomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);

    // Create wavy pattern
    final waveWidth = size.width / 5;
    for (int i = 0; i < 5; i++) {
      final x = i * waveWidth;
      path.quadraticBezierTo(x + waveWidth / 2, size.height, x + waveWidth, 0);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
