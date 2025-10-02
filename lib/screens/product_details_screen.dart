import 'package:e_com_app/models/cart_itrm.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String catogory;
  const ProductDetailScreen({super.key, required this.product, required this.catogory});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int qty = 1;
  bool _adding = false;

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    final data = await StorageService.readJson("cart.json");
    List<CartItem> cart = data.map((e) => CartItem.fromJson(e)).toList();

    final index = cart.indexWhere((c) => c.product.id == widget.product.id);
    if (index != -1) {
      cart[index].quantity += qty;
    } else {
      cart.add(CartItem(product: widget.product, quantity: qty));
    }

    await StorageService.writeJson("cart.json", cart.map((e) => e.toJson()).toList());
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to Cart"), duration: Duration(seconds: 1)),
    );
    setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade300,
        title: Text(p.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: SizedBox(
                 height: MediaQuery.of(context).size.height*0.4,
                  width:  MediaQuery.of(context).size.width,
                child: Image.asset(
                  p.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Title & Price
            Text(
              p.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "₹${p.price}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.purple.shade400),
            ),
             SizedBox(height:  MediaQuery.of(context).size.height*0.04),

            // Description Card
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(" Product Description :", textAlign:TextAlign.start,style:  TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Text(
                  p.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
             SizedBox(height: MediaQuery.of(context).size.height*0.1),

           // Quantity selector + Add to Cart button in same row
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Quantity selector
    Row(
      children: [
        IconButton(
          onPressed: () => setState(() => qty = (qty > 1) ? qty - 1 : 1),
          icon:  Icon(Icons.remove_circle, size: 32, color: Colors.purple.shade300),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Text("$qty", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        IconButton(
          onPressed: () => setState(() => qty++),
          icon:  Icon(Icons.add_circle, size: 32, color: Colors.purple.shade300),
        ),
      ],
    ),

    // Add to cart button
    Expanded(
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: ElevatedButton.icon(
            icon: _adding
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.add_shopping_cart, color: Colors.white,),
            label: Text(_adding ? "Adding..." : "Add to Cart", style: const TextStyle(fontSize: 16, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _adding ? null : _addToCart,
          ),
        ),
      ),
    ),
  ],
),

          ],
        ),
      ),
    );
  }
}
