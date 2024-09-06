import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_practice/post.dart';
import 'package:flutter/material.dart';
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
      // GoogleSignIn をして得られた情報を Firebase と関連づけることをやっています。
      final googleUser =
          await GoogleSignIn(scopes: ['profile', 'email']).signIn();

      if (googleUser == null) {
        // サインインがキャンセルされた場合の処理
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
      // エラーハンドリング
      print('Error signing in with Google: $e');
    }
  }

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
      bottomNavigationBar: const MenuTestBottomNavigationBar(),
      body: Center(
        child: ElevatedButton(
          child: const Text('GoogleSignIn'),
          onPressed: () async {
            await signInWithGoogle();
            // ログインが成功すると FirebaseAuth.instance.currentUser にログイン中のユーザーの情報が入ります
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
  // <> ここに変換したい型名をいれます。今回は Post です。
  fromFirestore: ((snapshot, _) {
    // 第二引数は使わないのでその場合は _ で不使用であることを分かりやすくしています。
    return Post.fromFirestore(snapshot); // 先ほど定期着した fromFirestore がここで活躍します。
  }),
  toFirestore: ((value, _) {
    return value.toMap(); // 先ほど適宜した toMap がここで活躍します。
  }),
);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
      ),
      body: Center(
        child: TextFormField(
          onFieldSubmitted: (text) {
            // まずは user という変数にログイン中のユーザーデータを格納します
            final user = FirebaseAuth.instance.currentUser!;

            final posterId = user.uid; // ログイン中のユーザーのIDがとれます
            final posterName = user.displayName!; // Googleアカウントの名前がとれます
            final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます

            // 先ほど作った postsReference からランダムなIDのドキュメントリファレンスを作成します
            // doc の引数を空にするとランダムなIDが採番されます
            final newDocumentReference = postsReference.doc();

            final newPost = Post(
              text: text,
              createdAt: Timestamp.now(), // 投稿日時は現在とします
              posterName: posterName,
              posterImageUrl: posterImageUrl,
              posterId: posterId,
              reference: newDocumentReference,
            );

            // 先ほど作った newDocumentReference のset関数を実行するとそのドキュメントにデータが保存されます。
            // 引数として Post インスタンスを渡します。
            // 通常は Map しか受け付けませんが、withConverter を使用したことにより Post インスタンスを受け取れるようになります。
            newDocumentReference.set(newPost);
          },
        ),
      ),
    );
  }
}
