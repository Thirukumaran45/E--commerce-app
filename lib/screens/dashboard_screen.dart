import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'category_products_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProfileScreen()),
  ),
  child: Padding(
    padding: const EdgeInsets.only(
      
      left: 10,
      bottom: 10
    ),
    child: CircleAvatar(
      radius: 10, 
      backgroundImage: AssetImage("assets/images/profile.jpg"),
      backgroundColor: Colors.grey[200], 
    ),
  ),
)
,
        backgroundColor: Colors.purple.shade300,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 30, color: Colors.white,),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
         
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildExpandedTile(context, 'Electronics', 'assets/images/electronic/laptop.jpg'),
                _buildExpandedTile(context, 'Books', 'assets/images/books/ai_book.jpg'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildExpandedTile(context, 'Clothing', 'assets/images/cloth/shirt.jpg'),
                _buildExpandedTile(context, 'Home', 'assets/images/home/sofa.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedTile(BuildContext context, String title, String assetPath) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: title)),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.shade100,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    width: MediaQuery.of(context).size.width*0.5,
                    height: MediaQuery.of(context).size.height*0.25,
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported,
                          size: 48, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
