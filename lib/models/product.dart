// lib/models/product.dart
class Product {
  final String id;
  final String title;
  final double price;
  final String description;
  final String image;
  int quantity;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final title = (json['title'] ?? json['name'] ?? '').toString();
    final description = (json['description'] ?? '').toString();
    final image = (json['image'] ?? '').toString();

    double parsePrice(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int parseQty(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final price = parsePrice(json['price']);
    final quantity = parseQty(json['quantity']);

    return Product(
      id: id,
      title: title,
      price: price,
      description: description,
      image: image,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'image': image,
        'quantity': quantity,
      };
}
