class TransactionItem {
  String? id; // Gunakan String untuk ID
  String itemId;
  String type; // 'in' atau 'out'
  int quantity;
  String date;

  TransactionItem({
    this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'type': type,
      'quantity': quantity,
      'date': date,
    };
  }

  static TransactionItem fromFirestore(String id, Map<String, dynamic> data) {
    return TransactionItem(
      id: id,
      itemId: data['itemId'],
      type: data['type'],
      quantity: data['quantity'],
      date: data['date'],
    );
  }
}
