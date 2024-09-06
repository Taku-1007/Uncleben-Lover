import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';

class SampleUrlLauncher extends StatefulWidget {
  const SampleUrlLauncher({super.key});
  @override
  State<StatefulWidget> createState() => _SampleUrlLauncher();
}

class _SampleUrlLauncher extends State<SampleUrlLauncher> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('url_launcher'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: const Text('Open URL in app'),
            onPressed: () {
              _launchInApp();
            },
          ),
          ElevatedButton(
            child: const Text('Open URL in browser'),
            onPressed: () {
              _launchInBrowser();
            },
          ),
          ElevatedButton(
            child: const Text('Open iOS Universal Link'),
            onPressed: () {
              _launchUniversalLinkIos();
            },
          ),
          ElevatedButton(
            child: const Text('Close after 5 seconds'),
            onPressed: () {
              _launchInApp();
              Timer(
                const Duration(seconds: 5),
                () {
                  closeInAppWebView();
                },
              );
            },
          ),
        ],
      )),
    );
  }

  // アプリ内で開く
  _launchInApp() async {
    const url = 'https://pub.dev/packages/url_launcher';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppWebView,
      );
    } else {
      throw 'このURLにはアクセスできません';
    }
  }

  // ブラウザで開く
  _launchInBrowser() async {
    const url = 'https://pub.dev/packages/url_launcher';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'This URL cannot be accessed';
    }
  }

  // ユニバーサルリンク
  _launchUniversalLinkIos() async {
    const url = 'https://www.youtube.com/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } else {
      throw 'This URL cannot be accessed';
    }
  }
}
