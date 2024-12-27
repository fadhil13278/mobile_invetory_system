class Item {
  String? id;
  String name;
  String description;
  double price;
  String category;
  String imagePath;
  int stock;
  String? supplierId;

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
    required this.stock,
    this.supplierId,
  });

  // Konversi ke format Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imagePath': imagePath,
      'stock': stock,
      'supplierId': supplierId,
    };
  }

  // Membuat object dari Firestore
  static Item fromFirestore(String id, Map<String, dynamic> data) {
    return Item(
      id: id,
      name: data['name'],
      description: data['description'],
      price: data['price'],
      category: data['category'],
      imagePath: data['imagePath'],
      stock: data['stock'],
      supplierId: data['supplierId'],
    );
  }
  Item copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imagePath,
    int? stock,
    String? supplierId,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      stock: stock ?? this.stock,
      supplierId: supplierId ?? this.supplierId,
    );
  }
}
