// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBbA0czkjcQ_JD8NaO0jNmG5zn3ZsxGDbw",
    authDomain: "redquackerp.firebaseapp.com",
    projectId: "redquackerp",
    storageBucket: "redquackerp.appspot.com",
    messagingSenderId: "1067733838888",
    appId: "1:1067733838888:web:4dfec4f9f21f407443d91d",
    measurementId: "G-Q0ZJ9MCYGY", // optional
  );
}
