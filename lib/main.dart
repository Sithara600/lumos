import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screen/first_screen/first_screen.dart';
import 'screen/patient_screen/home/home_patient.dart';
import 'screen/caregiver_screen/home/home_caregiver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Widget _initialScreen = const FirstScreen();

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  // Check if user is already logged in and determine their role
  Future<void> _checkCurrentUser() async {
    User? user = _authService.currentUser;
    
    if (user != null) {
      String? role = await _authService.getUserRole(user.uid);
      
      setState(() {
        if (role == 'patient') {
          _initialScreen = HomePatient();
        } else if (role == 'caregiver') {
          _initialScreen = HomeCaregiver();
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _initialScreen = const FirstScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumoss - Dementia Care',
      theme: ThemeData(
        primaryColor: const Color(0xFF9EC1FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9EC1FA)),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9EC1FA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
      home: _isLoading 
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _initialScreen,
    );
  }
}
