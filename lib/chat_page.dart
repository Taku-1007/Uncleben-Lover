import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_practice/news_bottom.dart';
import 'package:firebase_practice/post.dart';
import 'package:firebase_practice/my_page.dart';

final postsReference = //381行
    FirebaseFirestore.instance.collection('posts').withConverter<Post>(
  fromFirestore: ((snapshot, _) {
    return Post.fromFirestore(snapshot);
  }),
  toFirestore: ((value, _) {
    return value.toMap();
  }),
);

final reportsReference = FirebaseFirestore.instance.collection('reports');
final usersReference = FirebaseFirestore.instance.collection('users');
final blockedUsersReference =
    FirebaseFirestore.instance.collection('blockedUsers');

// 禁止ワードリストの作成
final List<String> bannedWords = ['badword1', 'badword2', 'badword3'];

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  final TextEditingController _editingController = TextEditingController();
  String? _editingPostId;
  final TextEditingController _replyController = TextEditingController();

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not signed in');
    }
    final storageRef = FirebaseStorage.instance.ref().child(
        'user_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(File(image.path));
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _editPost(Post post) async {
    setState(() {
      _editingController.text = post.text;
      _editingPostId = post.reference?.id;
    });
  }

  Future<void> _deletePost(DocumentReference postRef) async {
    await postRef.delete();
  }

  Future<void> _sendMessage() async {
    final text = _editingController.text.trim();
    if (text.isEmpty && _selectedImage == null) {
      return;
    }

    // 不適切なコンテンツをチェックする
    if (_containsBannedWords(text)) {
      _showErrorDialog('Your message contains inappropriate content.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog('User not signed in');
      return;
    }

    // ユーザーがブロックされているか確認する
    if (await _isUserBlocked(user.uid)) {
      _showErrorDialog('You are blocked from posting.');
      return;
    }

    final posterId = user.uid;
    final posterName =
        user.displayName ?? 'Anonymous'; // displayNameがnullの場合は'Anonymous'を使用
    final posterImageUrl = user.photoURL ?? ''; // photoURLがnullの場合は空文字を使用

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
    }

    if (_editingPostId != null) {
      // Update existing post
      final postRef = postsReference.doc(_editingPostId);
      await postRef.update({
        'text': text,
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });
      setState(() {
        _editingPostId = null;
        _editingController.clear();
      });
    } else {
      // Create new post
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
    }

    // Reset the selected image
    setState(() {
      _selectedImage = null;
      _editingController.clear();
    });
  }

  Future<void> _replyToPost(Post post) async {
    final replyText = _replyController.text.trim();
    if (replyText.isNotEmpty) {
      // 不適切なコンテンツをチェックする
      if (_containsBannedWords(replyText)) {
        _showErrorDialog('Your reply contains inappropriate content.');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('User not signed in');
        return;
      }

      // ユーザーがブロックされているか確認する
      if (await _isUserBlocked(user.uid)) {
        _showErrorDialog('You are blocked from posting.');
        return;
      }

      final reply = Reply(
        text: replyText,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
      );
      post.reference?.update({
        'replies': FieldValue.arrayUnion([reply.toMap()])
      });
      setState(() {
        _replyController.clear();
      });
    }
  }

  Future<void> _toggleHeart(Post post) async {
    final postRef = post.reference;
    if (postRef != null) {
      final snapshot = await postRef.get();
      final data = snapshot.data() as Map<String, dynamic>?;
      final currentHearts = data?['hearts'] ?? 0;

      postRef.update({
        'hearts': currentHearts + 1,
      });
    }
  }

  Future<void> _toggleReplyHeart(Post post, Reply reply) async {
    final postRef = post.reference;
    if (postRef != null) {
      final updatedReplies = post.replies.map((r) {
        if (r.text == reply.text && r.userId == reply.userId) {
          return Reply(
            text: r.text,
            userId: r.userId,
            userName: r.userName,
            hearts: r.hearts + 1,
          ).toMap();
        }
        return r.toMap();
      }).toList();

      postRef.update({'replies': updatedReplies});
    }
  }

  Future<void> _showReplyDialog(Post post) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add reply'),
          content: TextField(
            controller: _replyController,
            decoration:
                const InputDecoration(hintText: 'Please enter your reply'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _replyToPost(post);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reportPost(Post post) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Post'),
          content: const Text('Do you want to report this post?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  _showErrorDialog('User not signed in');
                  return;
                }
                final report = {
                  'reportedBy': user.uid,
                  'postId': post.reference?.id ?? '',
                  'reason': 'Inappropriate content',
                  'timestamp': Timestamp.now(),
                };
                await reportsReference.add(report);
                Navigator.of(context).pop();
                _showErrorDialog('The post has been reported.');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _blockUser(String userId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Block User'),
          content: const Text('Do you want to block this user?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await blockedUsersReference.doc(userId).set({
                    'blocked': true,
                    'timestamp': Timestamp.now(),
                  });
                  _showErrorDialog('The user has been blocked.');
                } catch (e) {
                  _showErrorDialog('Failed to block the user: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isUserBlocked(String userId) async {
    try {
      final doc = await blockedUsersReference.doc(userId).get();
      return doc.exists && doc.data()?['blocked'] == true;
    } catch (e) {
      _showErrorDialog('Failed to check block status: $e');
      return false;
    }
  }

  bool _containsBannedWords(String text) {
    for (var word in bannedWords) {
      if (text.contains(word)) {
        return true;
      }
    }
    return false;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const MyPage();
                  },
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: FirebaseAuth.instance.currentUser?.photoURL !=
                      null
                  ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                  : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
            ),
          )
        ],
        backgroundColor: const Color.fromRGBO(242, 167, 18, 1),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const NewsTestBottomNavigationBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Post>>(
              stream: postsReference.orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final post = docs[index].data();
                    return Card(
                      margin: EdgeInsets.all(screenWidth * 0.02),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: post.posterImageUrl.isNotEmpty
                                    ? NetworkImage(post.posterImageUrl)
                                    : const AssetImage(
                                            'assets/default_profile.png')
                                        as ImageProvider,
                              ),
                              title: Text(post.posterName),
                              subtitle: Text(
                                post.getFormattedDate(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editPost(post),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _deletePost(post.reference!),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.report),
                                    onPressed: () => _reportPost(post),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.block),
                                    onPressed: () => _blockUser(post.posterId),
                                  ),
                                ],
                              ),
                            ),
                            if (post.text.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.02),
                                child: Text(post.text),
                              ),
                            if (post.imageUrl != null &&
                                post.imageUrl!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.02),
                                child: Image.network(
                                  post.imageUrl!,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Image(
                                      image: AssetImage(
                                          'assets/default_image.png'),
                                    );
                                  },
                                ),
                              ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.reply),
                                  onPressed: () {
                                    _showReplyDialog(post);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: post.hearts > 0
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    _toggleHeart(post);
                                  },
                                ),
                                Text(post.hearts.toString()),
                              ],
                            ),
                            const Divider(),
                            ...post.replies.map(
                              (reply) => Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.02),
                                child: ListTile(
                                  title: Text(reply.userName),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(reply.text),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.favorite,
                                              color: reply.hearts > 0
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {
                                              _toggleReplyHeart(post, reply);
                                            },
                                          ),
                                          Text(reply.hearts.toString()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Image.file(
                File(_selectedImage!.path),
                height: 150,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _editingController,
                    decoration: const InputDecoration(
                      labelText: 'Please enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
