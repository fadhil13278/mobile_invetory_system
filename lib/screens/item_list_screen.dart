import 'dart:io';
import 'package:flutter/material.dart';
import 'detail_item_screen.dart';
import 'add_item_screen.dart';
import 'add_supplier_screen.dart';
import '../utils/database_helper.dart';
import '../models/item_model.dart';


class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late Future<List<Map<String, dynamic>>> _items;

  @override
  void initState() {
    super.initState();
    _items = DatabaseHelper().fetchItemsWithSuppliers();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _items = DatabaseHelper().fetchItemsWithSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Barang'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada barang.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(item['imagePath']),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.category, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(item['category']),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.group, size: 16, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                item['supplierName'] ?? 'Tidak ada pemasok',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.inventory, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Stok: ${item['stock']}'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('Rp ${item['price'].toStringAsFixed(0)}'),
                            ],
                          ),
                        ],
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailItemScreen(
                              item: Item.fromFirestore(item['id'], item),
                            ),
                          ),
                        );
                        if (result == true) {
                          _fetchItems();
                        }
                      },
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemScreen(
                    onItemAdded: _fetchItems,
                  ),
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.add),
            tooltip: 'Tambah Barang',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSupplierScreen(
                    onSupplierAdded: _fetchItems,
                  ),
                ),
              );
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.group_add),
            tooltip: 'Tambah Supplier',
          ),
        ],
      ),
    );
  }
}
