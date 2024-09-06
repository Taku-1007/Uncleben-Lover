import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_practice/home_bottom.dart';

// Firebase Storageから画像URLを取得する関数
Future<String> getImageUrl(String filePath) async {
  try {
    Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
    String downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('エラーが発生しました: $e');
    return '';
  }
}

class HomeScreen extends StatelessWidget {
  
  const HomeScreen({super.key});

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
          icon: Icon(Icons.menu),
          onPressed: () {
            // 必要に応じて動作を追加してください
          },
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<String>(
          future: getImageUrl(
              'Copy of UNCLE BEN HORIZONTAL LOGO[COLORED] copy 2 (1).png'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// 画像を表示するコンテナ
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(127, 38, 0, 1),
                          width: 4,
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: screenWidth,
                        height: screenHeight * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),

                    /// About Usセクション
                    Container(
                      margin: const EdgeInsets.all(16.0), // 全体に16ピクセルのマージンを追加
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(127, 38, 0, 1), // 赤色の境界線
                          width: 4.0, // 境界線の幅
                        ),
                      ),
                      child: Container(
                        color: const Color.fromRGBO(242, 167, 18, 1),
                        padding: const EdgeInsets.all(11),
                        child: Text(
                          'About us',
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(127, 38, 0, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Our café welcomes guests with a cozy atmosphere and fresh ingredients. Enjoy our fresh coffee and seasonal specialties. Relax and unwind with us.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: const Color.fromRGBO(127, 38, 0, 1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    /// Locationセクション
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(
                              127, 38, 0, 1), // Red border color
                          width: 4.0, // Border width
                        ),
                      ),
                      child: Container(
                        color: const Color.fromRGBO(242, 167, 18, 1),
                        padding: const EdgeInsets.all(11),
                        child: Text(
                          'Location',
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(127, 38, 0, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FutureBuilder<String>(
                                  future: getImageUrl(
                                      'pexels-fotios-photos-907142.jpg'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData &&
                                        snapshot.data!.isNotEmpty) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color.fromRGBO(
                                                127, 38, 0, 1),
                                            width: 4.0, // 枠線の幅
                                          ),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: snapshot.data!,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Enjoy a relaxing time and find moments of healing.',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromRGBO(127, 38, 0, 1),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(.0),
                                  child: Text(
                                    'Indulge in a Blissful Cup Found Nowhere Else.',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromRGBO(127, 38, 0, 1),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FutureBuilder<String>(
                                  future: getImageUrl('cafe-1869656_1280.jpg'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData &&
                                        snapshot.data!.isNotEmpty) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color.fromRGBO(
                                                127, 38, 0, 1),
                                            width: 4.0, // 枠線の幅
                                          ),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: snapshot.data!,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    FutureBuilder<String>(
                      future: getImageUrl('istockphoto-1145612951-612x612.jpg'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromRGBO(127, 38, 0, 1),
                                width: 4.0, // 枠線の幅
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data!,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Our café welcomes guests with a cozy atmosphere and fresh ingredients. Enjoy our fresh coffee and seasonal specialties. Relax and unwind with us.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: const Color.fromRGBO(127, 38, 0, 1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              } else {
                return Center(child: Text('No image data available'));
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      bottomNavigationBar: HomeTestBottomNavigationBar(),
    );
  }
}
