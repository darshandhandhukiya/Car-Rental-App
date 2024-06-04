import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditVehicleScreen extends StatefulWidget {
  final DocumentSnapshot car;

  const EditVehicleScreen({Key? key, required this.car}) : super(key: key);

  @override
  _EditCarScreenState createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditVehicleScreen> {
  late TextEditingController _nameController;
  late TextEditingController _modelController;
  late TextEditingController _colorController;
  late TextEditingController _detailController;
  late TextEditingController _priceController;

  File? _imageFile;
  String? _imageUrl;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.car['car_name']);
    _modelController = TextEditingController(text: widget.car['car_model']);
    _colorController = TextEditingController(text: widget.car['color']);
    _detailController = TextEditingController(text: widget.car['detail']);
    _priceController = TextEditingController(text: widget.car['price_per_day'].toString());
    _imageUrl = widget.car['car_images'][0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Tour Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Vehicles Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, 'Vehicle Name'),
              SizedBox(height: 15,),
              _buildTextField(_modelController, 'Vehicle Model'),
              SizedBox(height: 15,),
              _buildTextField(_colorController, 'Vehicle color'),
              SizedBox(height: 15,),
              _buildTextField(_detailController, 'Vehicle Detail'),
              SizedBox(height: 15,),
              _buildTextField(_priceController, 'Price per Day', keyboardType: TextInputType.number),
              SizedBox(height: 20),
              _buildButton('Save Changes', () {
                _updateCarDetails();
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildButton(String label, void Function()? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _updateCarDetails() async {
    try {
      await FirebaseFirestore.instance.collection('bus').doc(widget.car.id).update({
        'car_name': _nameController.text,
        'car_model': _modelController.text,
        'color': _colorController.text,
        'detail': _detailController.text,
        'price_per_day': double.parse(_priceController.text), // Parse as double
        // No need to update the image here
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Car details updated')));
    } catch (error) {
      print('Error updating car details: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update car details')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _detailController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
