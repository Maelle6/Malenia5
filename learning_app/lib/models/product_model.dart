class Product {
  String id;
  String title;
  String description;
  String category;
  String contactNum;
  String Address;
  double price;
  String imageUrl;
  String sellerId;
  final String? sellerName;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.contactNum,
    required this.Address,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    this.sellerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'contactNum': contactNum,
      'Address': Address,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      contactNum: map['contactNum'] ?? '',
      Address: map['Address'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'], // safely assign even if null
    );
  }
}
