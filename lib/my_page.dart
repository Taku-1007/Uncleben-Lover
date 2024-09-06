import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_practice/news_screen.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool _isEmailPrivate = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadUserSettings();
    }
  }

  Future<void> _loadUserSettings() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (userDoc.exists) {
      setState(() {
        _isEmailPrivate = userDoc['isEmailPrivate'] ?? false;
      });
    }
  }

  Future<void> _saveUserSettings() async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'isEmailPrivate': _isEmailPrivate,
    });
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await user?.delete();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NewsScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete account: $e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(127, 38, 0, 1),
        ),
        title: Text(
          'My Page',
          style: TextStyle(
            fontSize: screenWidth * 0.1,
            color: const Color.fromRGBO(127, 38, 0, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(242, 167, 18, 1),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(242, 167, 18, 1),
              Color.fromRGBO(242, 167, 18, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: user != null
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoURL ?? ''),
                      radius: screenWidth * 0.2,
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      user!.displayName ?? 'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.06,
                        color: const Color.fromRGBO(127, 38, 0, 1),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'UserID: ${user!.uid}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          color: const Color.fromRGBO(127, 38, 0, 1),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Registration date: ${user!.metadata.creationTime!}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          color: const Color.fromRGBO(127, 38, 0, 1),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const NewsScreen()),
                          (Route<dynamic> route) => false,
                        );
                        await GoogleSignIn().signOut();
                        await FirebaseAuth.instance.signOut();
                      },
                      icon: Icon(Icons.logout,
                          size: screenWidth * 0.05,
                          color: const Color.fromRGBO(127, 38, 0, 1)),
                      label: Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: const Color.fromRGBO(127, 38, 0, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                            horizontal: screenWidth * 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Account'),
                              content: const Text(
                                  'Are you sure you want to delete your account? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _deleteAccount(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.delete,
                          size: screenWidth * 0.05,
                          color: const Color.fromRGBO(127, 38, 0, 1)),
                      label: Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: const Color.fromRGBO(127, 38, 0, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                            horizontal: screenWidth * 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              )
            : Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const NewsScreen()),
                      (Route<dynamic> route) => false,
                    );
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: Icon(Icons.logout,
                      size: screenWidth * 0.05,
                      color: const Color.fromRGBO(127, 38, 0, 1)),
                  label: Text(
                    'Sign out',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: const Color.fromRGBO(127, 38, 0, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
