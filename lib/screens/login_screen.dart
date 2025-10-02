import 'package:e_com_app/providers/auth_provider.dart';
import 'package:e_com_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  final userProvider = Provider.of<AuthProvider>(context, listen: false);

  // Load the latest users from StorageService into the provider
  await userProvider.loadUser();

  final user = userProvider.user;
  if (user != null &&
      user['email'] == _emailCtrl.text.trim() &&
      user['password'] == _passCtrl.text) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Invalid credentials")));
  }
}

 InputDecoration _inputDecoration(String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: suffix,
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 600;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
         backgroundColor: Colors.purple.shade300,
        title: const Text('Login account',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
       
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 700 : mq.size.width),
          
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top image
                SizedBox(
                  height: isWide ? 240 : 280,
                  child: Image.asset(
                    'assets/images/ecom_login.jpg',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                // Welcome text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('E- Commerce App', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Online platform to purchase your needs', style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                          controller: _emailCtrl,
                          decoration: _inputDecoration('Enter your email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(v.trim())) return 'Enter valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passCtrl,
                          decoration: _inputDecoration('Enter your password', suffix: IconButton(
                            icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          )),
                          obscureText: _obscurePass,
                          validator: (v) => v == null || v.length < 4 ? 'Min 4 chars' : null,
                        ),
                       SizedBox(height: mq.size.height*0.1),
                      PrimaryButton(label: "Login", onPressed: ()=>_login()),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        ),
                        child: const Text("No account? Sign Up"),
                      )
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
