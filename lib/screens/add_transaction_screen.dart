import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/transaction_model.dart';
import '../utils/database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  final Item item;

  const AddTransactionScreen({super.key, required this.item});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _transactionType = 'in';
  final _quantityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late int _currentStock;

  @override
  void initState() {
    super.initState();
    _currentStock = widget.item.stock;
    _quantityController.addListener(_updateStockPreview);
  }

  void _updateStockPreview() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      if (_transactionType == 'in') {
        _currentStock = widget.item.stock + quantity;
      } else if (_transactionType == 'out') {
        _currentStock = widget.item.stock - quantity;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);

      if (_transactionType == 'out' && quantity > widget.item.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stok tidak mencukupi untuk barang keluar!')),
        );
        return;
      }

      final transactionItem = TransactionItem(
        itemId: widget.item.id!,
        type: _transactionType,
        quantity: quantity,
        date: _selectedDate.toIso8601String(),
      );
      await DatabaseHelper().insertTransaction(transactionItem);

      final updatedStock = _transactionType == 'in'
          ? widget.item.stock + quantity
          : widget.item.stock - quantity;
      final updatedItem = widget.item.copyWith(stock: updatedStock);
      await DatabaseHelper().updateItem(updatedItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Riwayat transaksi berhasil disimpan!')),
      );

      Navigator.pop(context, true);
    }
  }

  String _formatSelectedDate() {
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final year = _selectedDate.year;
    return '$day/$month/$year';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Riwayat Barang'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detail Barang',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.inventory, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  widget.item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.shopping_basket, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Stok Saat Ini: ${widget.item.stock}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.sync_alt, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Stok Setelah Transaksi: $_currentStock',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detail Transaksi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('Barang Masuk'),
                                    value: 'in',
                                    groupValue: _transactionType,
                                    onChanged: (value) {
                                      setState(() {
                                        _transactionType = value!;
                                        _updateStockPreview();
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('Barang Keluar'),
                                    value: 'out',
                                    groupValue: _transactionType,
                                    onChanged: (value) {
                                      setState(() {
                                        _transactionType = value!;
                                        _updateStockPreview();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Jumlah',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Jumlah harus diisi';
                                }
                                final number = int.tryParse(value);
                                if (number == null || number <= 0) {
                                  return 'Jumlah harus lebih dari 0';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Tanggal',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(_formatSelectedDate()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Simpan Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}