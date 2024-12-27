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

  // Convert to Firestore format
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

  // Create object from Firestore
  static Item fromFirestore(String id, Map<String, dynamic> data) {
    return Item(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      imagePath: data['imagePath'] ?? '',
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      supplierId: data['supplierId'],
    );
  }

  // Create object from Map (for local usage)
  static Item fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String?,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      imagePath: map['imagePath'] as String,
      stock: map['stock'] as int,
      supplierId: map['supplierId'] as String?,
    );
  }

  // Add copyWith method for convenience
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