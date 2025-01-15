import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard.dart';
import 'services/auth_service.dart';
import 'models/master_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDvOcDbamaIzVDt6rb6h2LyKPZ2Qxm_zJw",
      appId: "1:590835420327:android:8b766b006471561bdc9f82",
      messagingSenderId: "590835420327",
      projectId: "digital-standee-8653f",
      storageBucket: "digital-standee-8653f.firebasestorage.app",
      authDomain: "digital-standee-8653f.firebaseapp.com",
    ),
  );
  runApp(MasterApp());
}

class MasterApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Signage Master',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<MasterUser?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data != null) {
            return Dashboard();
          }

          return LoginScreen();
        },
      ),
    );
  }
}