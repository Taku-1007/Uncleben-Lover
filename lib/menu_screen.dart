import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_practice/menu_bottom.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
      bottomNavigationBar:
          const MenuTestBottomNavigationBar(), // ボトムナビゲーションバーを追加
    );
  }
}
