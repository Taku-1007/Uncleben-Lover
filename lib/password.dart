import 'package:flutter/material.dart';
import 'package:firebase_practice/menu_image.dart'; // 修正: menu_image.dart をインポート

class PasswordScreen extends StatefulWidget {
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _passwordController = TextEditingController();
  final String _correctPassword = 'avicii107'; //パスワード

  void _checkPassword() {
    if (_passwordController.text == _correctPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuImage()), // 修正: 名前付きルートを使用
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect Password!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enter Password',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            color: const Color.fromRGBO(127, 38, 0, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(242, 167, 18, 1), // AppBarの背景色を設定
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(242, 167, 18, 1),
              const Color.fromRGBO(242, 167, 18, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '<This is the staff management screen>',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: const Color.fromRGBO(127, 38, 0, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Enter Password',
                  labelStyle: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: const Color.fromRGBO(127, 38, 0, 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: const Color.fromRGBO(127, 38, 0, 1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: const Color.fromRGBO(127, 38, 0, 1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                obscureText: true,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: const Color.fromRGBO(127, 38, 0, 1),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              ElevatedButton(
                onPressed: _checkPassword,
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: const Color.fromRGBO(127, 38, 0, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
