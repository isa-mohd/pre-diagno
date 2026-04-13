import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCx1BxN5WC_KVU26TtOVeU9smzzHqxr4yY",
            authDomain: "pre-daigno-wm9ma6.firebaseapp.com",
            projectId: "pre-daigno-wm9ma6",
            storageBucket: "pre-daigno-wm9ma6.firebasestorage.app",
            messagingSenderId: "885732558053",
            appId: "1:885732558053:web:9d719295de122e2b4a000c",
            measurementId: "G-W5FMSVR481"));
  } else {
    await Firebase.initializeApp();
  }
}
