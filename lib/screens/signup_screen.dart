import 'package:e_com_app/providers/auth_provider.dart';
import 'package:e_com_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
   final  _nameCtrl= TextEditingController();
   final  _emailCtrl= TextEditingController();
   final  _passCtrl= TextEditingController();
   final  _confirmCtrl= TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

 Future<void> _signUp() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _loading = true;
  });

  try {
    final userProvider = Provider.of<AuthProvider>(context, listen: false);

    // Load existing users from provider
    await userProvider.loadUser(); // optional, if you want latest

    final existingUsers = await StorageService.readJson('users.json'); // still need to check duplicates

    bool emailExists = existingUsers.any((u) => u['email'] == _emailCtrl.text.trim());

    if (emailExists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already exists!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Create user
    final newUser = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text,
    };

    // Add user to provider (and save to JSON)
    await userProvider.addUser(newUser);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
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
        title: const Text('Create Account',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        leading: IconButton(
          onPressed: ()=> Navigator.pop(context),
          icon: Icon(Icons.arrow_back,color: Colors.white,)),
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
                  height: isWide ? 240 : 180,
                  child: Image.asset(
                    'assets/images/ecom_regis.jpg',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                // Welcome text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Welcome!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Create an account to continue', style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 22),

                // Form Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: _inputDecoration('Full Name'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: _inputDecoration('Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(v.trim())) return 'Enter valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passCtrl,
                          decoration: _inputDecoration('Password', suffix: IconButton(
                            icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          )),
                          obscureText: _obscurePass,
                          validator: (v) => v == null || v.length < 4 ? 'Min 4 chars' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmCtrl,
                          decoration: _inputDecoration('Confirm Password', suffix: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          )),
                          obscureText: _obscureConfirm,
                          validator: (v) => v != _passCtrl.text ? "Passwords don't match" : null,
                        ),
                
                         SizedBox(height: mq.size.height*0.1),
                
                        // Custom button widget
                        PrimaryButton(
                          label: _loading ? 'Signing up...' : 'Create Account',
                          onPressed: _loading ? null : _signUp,
                          loading: _loading,
                        ),
                
                        const SizedBox(height: 8),
                
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: const Text('Already have an account? Log in'),
                        ),
                      ],
                    ),
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
