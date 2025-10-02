import 'package:e_com_app/models/cart_itrm.dart';
import 'package:e_com_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cart = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final data = await StorageService.readJson("cart.json");
    setState(() {
      cart = data.map((e) => CartItem.fromJson(e)).toList();
    });
  }

  Future<void> _updateCart() async {
    await StorageService.writeJson("cart.json", cart.map((e) => e.toJson()).toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final total = cart.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    final total_cost = total+70.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text("Cart items ",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.purple.shade400,
      ),
      body: cart.isEmpty
          ? const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      final item = cart[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  item.product.image,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Product Details
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${item.product.price} x ${item.quantity}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cart.removeAt(i);
                                  _updateCart();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                        children: [
                          const Text(
                            "Total Product cost :",
                            style: TextStyle(fontSize: 20,  color: Colors.black),
                          ),
                          Text(
                            "₹${total.toStringAsFixed(2)}",
                            style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                        ],
                      ), Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                        children: [
                          const Text(
                            "Delivery cost :",
                            style: TextStyle(fontSize: 20,  color: Colors.black),
                          ),
                          Text(
                            "₹50",
                            style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                        ],
                      ), Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "GST cost :",
                            style: TextStyle(fontSize: 20,  color: Colors.black),
                          ),
                          Text(
                            "₹20",
                            style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total pay:",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          Text(
                            "₹$total_cost",
                            style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PrimaryButton(label: "Pay now", onPressed: (){}),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.03,)
              ],
            ),
    );
  }
}
