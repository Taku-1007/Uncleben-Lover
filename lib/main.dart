import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:firebase_practice/post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

// Firestoreのコレクションリファレンスの初期化
final postsReference =
    FirebaseFirestore.instance.collection('posts').withConverter<Post>(
  fromFirestore: (snapshot, _) {
    return Post.fromFirestore(snapshot);
  },
  toFirestore: (post, _) {
    return post.toMap();
  },
);
