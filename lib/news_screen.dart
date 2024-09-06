import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_practice/post.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_practice/menu_bottom.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  Future<void> signInWithGoogle() async {
    try {
      final googleUser =
          await GoogleSignIn(scopes: ['profile', 'email']).signIn();

      if (googleUser == null) {
        print('Sign in aborted by user');
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Uncle Ben',
          style: TextStyle(
            fontSize: screenWidth * 0.1,
            color: const Color.fromRGBO(127, 38, 0, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(242, 167, 18, 1),
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/leading.svg'),
          onPressed: () {
            // 必要に応じて動作を追加してください
          },
        ),
      ),
      bottomNavigationBar: const MenuTestBottomNavigationBar(),
      body: Center(
        child: ElevatedButton(
          child: const Text('GoogleSignIn'),
          onPressed: () async {
            await signInWithGoogle();
            print(FirebaseAuth.instance.currentUser?.displayName);
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
                  return const ChatPage();
                }),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}

final postsReference =
    FirebaseFirestore.instance.collection('posts').withConverter<Post>(
  fromFirestore: ((snapshot, _) {
    return Post.fromFirestore(snapshot);
  }),
  toFirestore: ((value, _) {
    return value.toMap();
  }),
);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _selectedImage = image;
      });
    } else {
      print('Permission denied');
    }
  }

  Future<String> _uploadImage(XFile image) async {
    final user = FirebaseAuth.instance.currentUser!;
    final storageRef = FirebaseStorage.instance.ref().child(
        'user_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(File(image.path));
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Uncle Ben',
          style: TextStyle(
            fontSize: screenWidth * 0.1,
            color: const Color.fromRGBO(127, 38, 0, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(242, 167, 18, 1),
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/leading.svg'),
          onPressed: () {
            // 必要に応じて動作を追加してください
          },
        ),
      ),
      bottomNavigationBar: const MenuTestBottomNavigationBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Post>>(
              stream: postsReference.orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final post = docs[index].data();
                    return ListTile(
                      title: Text(post.text),
                      subtitle: post.imageUrl != null
                          ? Image.network(post.imageUrl!)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(_selectedImage!.path),
                height: 150,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'メッセージを入力してください',
                    ),
                    onFieldSubmitted: (text) async {
                      final user = FirebaseAuth.instance.currentUser!;

                      final posterId = user.uid;
                      final posterName = user.displayName!;
                      final posterImageUrl = user.photoURL!;

                      String? imageUrl;
                      if (_selectedImage != null) {
                        imageUrl = await _uploadImage(_selectedImage!);
                      }

                      final newDocumentReference = postsReference.doc();

                      final newPost = Post(
                        text: text,
                        createdAt: Timestamp.now(),
                        posterName: posterName,
                        posterImageUrl: posterImageUrl,
                        posterId: posterId,
                        reference: newDocumentReference,
                        imageUrl: imageUrl,
                      );

                      newDocumentReference.set(newPost);

                      // Reset the selected image
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
