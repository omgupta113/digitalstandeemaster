import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Digital Signage Master',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 30),
            GoogleSignInButton(
              onPressed: () async {
                try {
                  final user = await _authService.signInWithGoogle();
                  if (user != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing in: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}