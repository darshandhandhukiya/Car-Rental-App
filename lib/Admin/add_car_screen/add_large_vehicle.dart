import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LargeImageUploadScreen extends StatefulWidget {
  @override
  _CarImageUploadScreenState createState() => _CarImageUploadScreenState();
}

class _CarImageUploadScreenState extends State<LargeImageUploadScreen> {
  List<File?> _images = List.filled(3, null);
  List<TextEditingController> _controllers =
  List.generate(5, (_) => TextEditingController());
  List<String> _imageURLs = [];

  Future<void> _getImage(int index) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _images[index] = File(pickedImage.path);
      }
    });
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.png';
      final Reference ref = storage.ref().child('car_images/$fileName');
      final UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask;
      final String imageURL = await ref.getDownloadURL();
      return imageURL;
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  Future<void> _saveCarData() async {
    try {
      String carName = _controllers[0].text;
      String carDetails = _controllers[1].text;
      String carColor = _controllers[2].text;
      String carModel = _controllers[3].text;
      double pricePerDay = double.tryParse(_controllers[4].text) ?? 0.0;

      for (int i = 0; i < _images.length; i++) {
        if (_images[i] != null) {
          String imageURL = await uploadImageToStorage(_images[i]!);
          if (imageURL.isNotEmpty) {
            _imageURLs.add(imageURL);
          } else {
            // Handle error while uploading image
          }
        }
      }

      await FirebaseFirestore.instance.collection('bus').add({
        'car_images': _imageURLs,
        'car_name': carName,
        'detail': carDetails,
        'color': carColor,
        'car_model': carModel,
        'price_per_day': pricePerDay,
      });

      // Clear text fields after saving
      for (var controller in _controllers) {
        controller.clear();
      }

      // Clear selected images after saving
      setState(() {
        _images = List.filled(3, null);
      });

      // Show success message or navigate to next screen
    } catch (error) {
      print('Error saving car data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Tour Vehicle'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            for (int i = 0; i < _images.length; i++)
              GestureDetector(
                onTap: () => _getImage(i),
                child: Container(
                  height: 150,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: _images[i] == null
                      ? Center(
                      child: Icon(Icons.add, size: 50, color: Colors.grey))
                      : Image.file(_images[i]!, fit: BoxFit.cover),
                ),
              ),
            SizedBox(height: 20),
            for (int i = 0; i < _controllers.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: _controllers[i],
                  decoration: InputDecoration(
                    labelText: i == 0
                        ? 'Vehicle Name'
                        : i == 1
                        ? 'Vehicle Details'
                        : i == 2
                        ? 'Vehicle Color'
                        : i == 3
                        ? 'Vehicle Model'
                        : 'Price Per Day',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () async {
                if (_images.any((image) => image != null)) {
                  await _saveCarData();
                } else {
                  // No image selected
                  print("No image selected");
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                    child: Text(
                      'UPLOAD DATA',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    )),
              ),
            )
          ],
        ),

      ),
    );
  }
}
