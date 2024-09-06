import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_practice/news_screen.dart';
import 'package:firebase_practice/home_screen.dart';

class MenuTestBottomNavigationBar extends StatefulWidget {
  const MenuTestBottomNavigationBar({super.key});

  @override
  State<MenuTestBottomNavigationBar> createState() =>
      _MenuTestBottomNavigationBarState();
}

class _MenuTestBottomNavigationBarState
    extends State<MenuTestBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print("タップされた場所は" + _selectedIndex.toString());

      // 対応するインデックスに基づいて画面遷移を行う
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double iconSize =
        MediaQuery.of(context).size.width * 0.09; // デバイス幅の7%をアイコンサイズに設定

    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/home.svg',
            height: iconSize,
            width: iconSize,
          ),
          label: '', // 空のラベルを設定
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/cup.svg',
            height: iconSize,
            width: iconSize,
          ),
          label: '', // 空のラベルを設定
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/news.svg',
            height: iconSize,
            width: iconSize,
          ),
          label: '', // 空のラベルを設定
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      showSelectedLabels: false, // 選択されたラベルを表示しない
      showUnselectedLabels: false, // 選択されていないラベルを表示しない
    );
  }
}
