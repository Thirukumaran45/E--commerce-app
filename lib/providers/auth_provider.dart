import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  // Load user from JSON
  Future<void> loadUser() async {
    final users = await StorageService.readJson("users.json");
    if (users.isNotEmpty) {
      _user = users.last; // latest signed-up user
    } else {
      _user = null;
    }
    notifyListeners(); // notify UI to rebuild
  }

  // Add a new user
  Future<void> addUser(Map<String, dynamic> newUser) async {
    final users = await StorageService.readJson("users.json");
    users.add(newUser);
    await StorageService.writeJson("users.json", users);
    _user = newUser;
    notifyListeners();
  }

  // Logout user
  void logout() {
    _user = null;
    notifyListeners();
  }
}
