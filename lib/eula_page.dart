import 'package:flutter/material.dart';
import 'package:firebase_practice/main.dart';
import 'package:firebase_practice/news_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EulaPage extends StatefulWidget {
  @override
  _EulaPageState createState() => _EulaPageState();
}

class _EulaPageState extends State<EulaPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_scrollController.position.outOfRange) {
        setState(() {
          _isScrolledToEnd = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _acceptEula() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acceptedEula', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => AuthCheck()), // EULA同意後にAuthCheckを表示
    );
  }

  void _cancelEula() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const NewsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('End User License Agreement'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  '''End User License Agreement (EULA)
                  
Welcome to our app! Please read the following terms and conditions carefully before using our services. By using this app, you agree to comply with and be bound by these terms.

1. **Respectful Communication**: Users must engage in respectful and courteous communication. Any form of harassment, bullying, or hate speech is strictly prohibited.

2. **Appropriate Content**: Users should not post any inappropriate content, including but not limited to, offensive, defamatory, or obscene material.

3. **Enjoy and Have Fun**: We encourage all users to enjoy the app and have fun while using it. Please be considerate of others and contribute positively to the community.

4. **Reporting Issues**: If you encounter any inappropriate content or behavior, please report it immediately using the provided reporting tools.

5. **Compliance with Laws**: Users must comply with all applicable laws and regulations while using the app.

6. **Account Responsibility**: Users are responsible for maintaining the confidentiality of their account information and for all activities that occur under their account.

7. **Report Inappropriate Content**: Users have the ability to report any inappropriate content using the provided reporting tools.

8. **Block Misconduct Users**: Users can block other users who engage in misconduct.

9. **Developer's Response to Reports**: Developers will address reports of inappropriate content within 24 hours, remove the content, and ban the users who caused the issues.

By tapping "Accept", you acknowledge that you have read, understood, and agree to be bound by these terms. If you do not agree to these terms, please do not use our app.

Thank you for being a part of our community!
''',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isScrolledToEnd ? _acceptEula : null,
                  child: Text('Accept',
                      style: TextStyle(fontSize: screenWidth * 0.05)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02),
                  ),
                ),
                ElevatedButton(
                  onPressed: _cancelEula,
                  child: Text('Cancel',
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
}
