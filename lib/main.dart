import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    print('✅ Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    
    // Test Firestore connection
    await _testFirestoreConnection();
    
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

Future<void> _testFirestoreConnection() async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    print('🔄 Testing Firestore connection...');
    
    // Test write
    final docRef = await firestore.collection('connection_test').add({
      'test': 'Firestore is working!',
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('✅ Firestore write successful! Document ID: ${docRef.id}');
    
    // Test read
    final doc = await docRef.get();
    print('✅ Firestore read successful! Data: ${doc.data()}');
    
    // Clean up
    await docRef.delete();
    print('✅ Firestore cleanup successful!');
    
  } catch (e) {
    print('❌ Firestore test failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chat Boards",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}