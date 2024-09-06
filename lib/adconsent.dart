import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_practice/main.dart'; // AuthCheckをインポート

class AdConsentPage extends StatefulWidget {
  @override
  _AdConsentPageState createState() => _AdConsentPageState();
}

class _AdConsentPageState extends State<AdConsentPage> {
  Future<void> _acceptAds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adConsentGiven', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthCheck()),
    );
  }

  Future<void> _declineAds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adConsentGiven', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthCheck()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Consent'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Would you like to see ads in the app to support our service?',
              style: TextStyle(fontSize: screenWidth * 0.05),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _acceptAds,
                  child: Text('Yes',
                      style: TextStyle(fontSize: screenWidth * 0.05)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02),
                  ),
                ),
                ElevatedButton(
                  onPressed: _declineAds,
                  child: Text('No',
                      style: TextStyle(fontSize: screenWidth * 0.05)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}//962 331 7962
