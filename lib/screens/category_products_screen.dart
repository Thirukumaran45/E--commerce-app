// lib/screens/category_products_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  bool _loading = true;
  String _error = '';
  List<Product> _products = [];
  List<Product> _filtered = [];
  String _sortType = 'name';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<File> _documentsProductsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/products.json');
  }

  Future<String> _readProductsJsonString() async {
    try {
      final file = await _documentsProductsFile();
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {
      // ignore
    }
    // fallback to asset bundled with app
    return await rootBundle.loadString('assets/products.json');
  }

  List<Product> _safeProductListFrom(dynamic raw) {
    final out = <Product>[];
    if (raw is! List) return out;
    for (var e in raw) {
      if (e is Map<String, dynamic>) {
        try {
          final p = Product.fromJson(e);
          // skip if both id and title missing
          if (p.id.isEmpty && p.title.isEmpty) continue;
          out.add(p);
        } catch (err) {
          debugPrint('Skipping malformed product: $e => $err');
        }
      }
    }
    return out;
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = '';
      _products = [];
      _filtered = [];
    });

    try {
      final jsonStr = await _readProductsJsonString();
      final decoded = jsonDecode(jsonStr);

      // Expect structure: { "categories": [ { "id": "...", "title": "...", "products": [ ... ] }, ... ] }
      if (decoded is Map<String, dynamic> && decoded.containsKey('categories')) {
        final cats = decoded['categories'] as List<dynamic>;
        Map<String, dynamic>? matchedCat;
        for (var c in cats) {
          if (c is Map<String, dynamic>) {
            final id = (c['id'] ?? '').toString();
            final title = (c['title'] ?? c['name'] ?? '').toString();
            if (id.toLowerCase() == widget.category.toLowerCase() ||
                title.toLowerCase() == widget.category.toLowerCase()) {
              matchedCat = c;
              break;
            }
          }
        }

        if (matchedCat != null) {
          final rawProducts = matchedCat['products'];
          _products = _safeProductListFrom(rawProducts);
        } else {
          // nothing matched, but we can try flattening all products from all categories
          final flattened = <Product>[];
          for (var c in cats) {
            if (c is Map<String, dynamic> && c['products'] is List) {
              flattened.addAll(_safeProductListFrom(c['products']));
            }
          }
          _products = flattened;
        }
      } else {
        // other shapes: try find a top-level 'products' or a top-level list
        if (decoded is Map<String, dynamic> && decoded.containsKey('products')) {
          _products = _safeProductListFrom(decoded['products']);
        } else if (decoded is List) {
          _products = _safeProductListFrom(decoded);
        } else {
          throw Exception('Unexpected JSON shape for products file');
        }
      }

      // Apply initial filter & sort
      _applyFilters();
      debugPrint('Loaded ${_products.length} products for category "${widget.category}"');
    } catch (e, st) {
      debugPrint('Error loading products: $e\n$st');
      setState(() {
        _error = 'Failed to load products';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    _filtered = _products.where((p) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return p.title.toLowerCase().contains(q) || p.description.toLowerCase().contains(q);
    }).toList();

    if (_sortType == 'name') {
      _filtered.sort((a, b) => a.title.compareTo(b.title));
    } else {
      _filtered.sort((a, b) => a.price.compareTo(b.price));
    }
    setState(() {});
  }

  Widget _imageFor(Product p, {double width = 56, double height = 56}) {
    final img = p.image;
    if (img.startsWith('http')) {
      return Image.network(img, width: width, height: height, fit: BoxFit.cover);
    } else if (img.isNotEmpty) {
      // treat as asset path
      return Image.asset(img, width: width, height: height, fit: BoxFit.cover, errorBuilder: (_,__,___){
        return Container(width: width, height: height, color: Colors.grey[200], child: const Icon(Icons.image));
      });
    } else {
      return Container(width: width, height: height, color: Colors.grey[200], child: const Icon(Icons.image));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.arrow_back, color: Colors.white,) ),
        backgroundColor: Colors.purple.shade300,
        title: Text(widget.category, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        actions: [
          IconButton(icon: const Icon(Icons.refresh,color: Colors.white,), onPressed: _loadProducts),
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (v) {
              _sortType = v;
              _applyFilters();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'name', child: Text('Name')),
              PopupMenuItem(value: 'price', child: Text('Price')),
            ],
          )
        ],
        bottom: PreferredSize(
  preferredSize: const Size.fromHeight(56),
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      style: const TextStyle(color: Colors.black), // text color
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.black), // icon color
        hintText: 'Search products',
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white, // background color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // remove default border
        ),
      ),
      onChanged: (v) {
        _query = v;
        _applyFilters();
      },
    ),
  ),
),

      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _filtered.isEmpty
                  ? Center(child: Text('No products found in "${widget.category}"'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = _filtered[index];
                        return Card(
                          child: ListTile(
                            leading: _imageFor(p, width: 64, height: 64),
                            title: Text(p.title),
                            subtitle: Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Text('₹${p.price.toStringAsFixed(0)}'),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p, catogory: widget.category,))),
                          ),
                        );
                      },
                    ),
    );
  }
}
