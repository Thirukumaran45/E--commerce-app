import 'dart:io';
import 'package:e_com_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await _initProductsJson();
  runApp(MultiProvider(
    providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),],
    child: const MyApp()));
}

Future<void> _initProductsJson() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/products.json');

    if (!await file.exists()) {
      final data = await rootBundle.loadString('assets/products.json');
      await file.writeAsString(data);
    }
  } catch (e, st) {
    debugPrint('Error while initializing products.json: $e\n$st');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Local Shop',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      
      home: FutureBuilder<bool>(
        future: _checkLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data! ? const DashboardScreen() : const LoginScreen();
        },
      ),
    );
  }
}
