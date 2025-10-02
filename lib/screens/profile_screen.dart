import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _getUser() async {
    final users = await StorageService.readJson("users.json");
    if (users.isNotEmpty) {
      return users.last; // get latest signed-up user
    }
    return null;
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> Navigator.pop(context), icon: Icon(Icons.arrow_back, color: Colors.white,) ),
        backgroundColor: Colors.purple.shade300,
        title:  Text(" Profile", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _getUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data as Map<String, dynamic>;

          return Stack(
            children: [
              // Gradient Background
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Top Profile Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.green,
                        child: Text(
                          user['name'][0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // User Info Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'],
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.email,
                                      color: Colors.blueAccent),
                                  const SizedBox(width: 10),
                                  Text(
                                    user['email'],
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black54),
                                  ),
                                ],
                              ),
                              // Add more user info here if needed
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout,color: Colors.white,),
                          label: const Text(
                            "Logout",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
