import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class MenuImage extends StatefulWidget {
  const MenuImage({super.key});
  @override
  _MenuImageState createState() => _MenuImageState(); //ここを後で修正してください。6/13
}

class _MenuImageState extends State<MenuImage> {
  File? _image;
  final _menuController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndMenu() async {
    if (_image == null || _menuController.text.isEmpty) return;

    final storageRef = FirebaseStorage.instance.ref();
    final imagesRef =
        storageRef.child("images/${DateTime.now().millisecondsSinceEpoch}.png");

    try {
      await imagesRef.putFile(_image!);
      final downloadURL = await imagesRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('menus').add({
        'imageUrl': downloadURL,
        'menu': _menuController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image and menu uploaded successfully!')),
      );
      Navigator.pop(context, downloadURL);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _deleteMenu(DocumentSnapshot doc) async {
    try {
      await FirebaseStorage.instance.refFromURL(doc['imageUrl']).delete();
      await FirebaseFirestore.instance.collection('menus').doc(doc.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting menu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete menu!')),
      );
    }
  }

  Future<void> _editMenu(DocumentSnapshot doc) async {
    final TextEditingController editController =
        TextEditingController(text: doc['menu']);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Menu'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: 'Menu Description'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                if (editController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('menus')
                      .doc(doc.id)
                      .update({'menu': editController.text});
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Menu updated successfully!')),
                  );
                }
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu Image',
          style: TextStyle(
            fontSize: screenWidth * 0.08,
            color: const Color.fromRGBO(127, 38, 0, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(242, 167, 18, 1),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color.fromRGBO(242, 167, 18, 1), // 背景色を一色に設定
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text(
                    'No image selected.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      color: const Color.fromRGBO(127, 38, 0, 1),
                    ),
                  )
                : Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(127, 38, 0, 1),
                      ),
                    ),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: _menuController,
              decoration: InputDecoration(
                labelText: 'Enter Menu Description',
                labelStyle: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: const Color.fromRGBO(127, 38, 0, 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image, size: screenWidth * 0.05),
              label: Text('Pick Image',
                  style: TextStyle(fontSize: screenWidth * 0.04)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton.icon(
              onPressed: _uploadImageAndMenu,
              icon: Icon(Icons.upload, size: screenWidth * 0.05),
              label: Text('Upload Image and Menu',
                  style: TextStyle(fontSize: screenWidth * 0.04)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('menus').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        margin:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        child: ListTile(
                          leading: Image.network(
                            doc['imageUrl'],
                            width: screenWidth * 0.15,
                            height: screenHeight * 0.1,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            doc['menu'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: const Color.fromRGBO(127, 38, 0, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit,
                                    size: screenWidth * 0.05,
                                    color: const Color.fromRGBO(127, 38, 0, 1)),
                                onPressed: () => _editMenu(doc),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    size: screenWidth * 0.05,
                                    color: const Color.fromRGBO(127, 38, 0, 1)),
                                onPressed: () => _deleteMenu(doc),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
