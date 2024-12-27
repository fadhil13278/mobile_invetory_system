import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../models/supplier_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  // Fetch Items with Suppliers
  Future<List<Map<String, dynamic>>> fetchItemsWithSuppliers() async {
    try {
      final itemsSnapshot = await _firestore.collection('items').get();
      final suppliersSnapshot = await _firestore.collection('suppliers').get();

      // Create a map of supplier IDs to supplier names
      final supplierMap = {
        for (var doc in suppliersSnapshot.docs)
          doc.id: doc.data()['name'] as String
      };

      final List<Map<String, dynamic>> items = [];
      for (var doc in itemsSnapshot.docs) {
        final data = doc.data();
        items.add({
          'id': doc.id,
          ...data,
          'supplierName': data['supplierId'] != null
              ? supplierMap[data['supplierId']]
              : 'No Supplier'
        });
      }
      return items;
    } catch (e) {
      print("Error fetching items with suppliers: $e");
      throw e;
    }
  }

  // Other methods remain the same...
  Future<List<Supplier>> fetchSuppliers() async {
    try {
      final querySnapshot = await _firestore.collection('suppliers').get();
      return querySnapshot.docs
          .map((doc) => Supplier.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching suppliers: $e");
      throw e;
    }
  }

  Future<void> insertSupplier(Supplier supplier) async {
    try {
      await _firestore.collection('suppliers').add(supplier.toFirestore());
    } catch (e) {
      print("Error inserting supplier: $e");
      throw e;
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      if (supplier.id == null) throw Exception("Supplier ID is null");
      await _firestore
          .collection('suppliers')
          .doc(supplier.id)
          .update(supplier.toFirestore());
    } catch (e) {
      print("Error updating supplier: $e");
      throw e;
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _firestore.collection('suppliers').doc(id).delete();
    } catch (e) {
      print("Error deleting supplier: $e");
      throw e;
    }
  }

  Future<void> insertItem(Item item) async {
    try {
      await _firestore.collection('items').add(item.toFirestore());
    } catch (e) {
      print("Error inserting item: $e");
      throw e;
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      if (item.id == null) throw Exception("Item ID is null");
      await _firestore.collection('items').doc(item.id).update(item.toFirestore());
    } catch (e) {
      print("Error updating item: $e");
      throw e;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection('items').doc(id).delete();
    } catch (e) {
      print("Error deleting item: $e");
      throw e;
    }
  }

  Future<int> getItemCount() async {
    try {
      final snapshot = await _firestore.collection('items').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching item count: $e');
      return 0;
    }
  }

  Future<void> insertTransaction(TransactionItem transaction) async {
    try {
      await _firestore.collection('transactions').add(transaction.toFirestore());
    } catch (e) {
      print("Error inserting transaction: $e");
      throw e;
    }
  }

  Future<int> getTotalStock() async {
    try {
      final snapshot = await _firestore.collection('items').get();
      return snapshot.docs.fold<int>(0, (total, doc) {
        return total + (doc.data()['stock'] as int? ?? 0);
      });
    } catch (e) {
      print('Error fetching total stock: $e');
      return 0;
    }
  }

  Future<int> getSupplierCount() async {
    try {
      final snapshot = await _firestore.collection('suppliers').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error fetching supplier count: $e');
      return 0;
    }
  }
}