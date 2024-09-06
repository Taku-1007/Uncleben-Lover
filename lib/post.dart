import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String text;
  final String posterName;
  final String posterImageUrl;
  final String posterId;
  final Timestamp createdAt;
  final DocumentReference reference;
  final String? imageUrl; // ここにimageUrlを追加

  Post({
    required this.text,
    required this.posterName,
    required this.posterImageUrl,
    required this.posterId,
    required this.createdAt,
    required this.reference,
    this.imageUrl, // コンストラクタに追加
  });

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Post(
      text: data['text'],
      posterName: data['posterName'],
      posterImageUrl: data['posterImageUrl'],
      posterId: data['posterId'],
      createdAt: data['createdAt'],
      reference: snapshot.reference,
      imageUrl: data['imageUrl'], // ここを追加
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'posterName': posterName,
      'posterImageUrl': posterImageUrl,
      'posterId': posterId,
      'createdAt': createdAt,
      'imageUrl': imageUrl, // ここを追加
    };
  }
}
