import 'package:cab_ex/Admin/car_detail/edit_vehicle/edit_tour_vehicle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_vehicle/edit_car_screen.dart';

class TourVehicleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bus').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No cars found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot car = snapshot.data!.docs[index];
              List<String> carImages = List<String>.from(car['car_images']);
              String firstImage = carImages.isNotEmpty ? carImages[0] : '';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 165,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 160,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(firstImage),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car['car_name'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                car['car_model'],
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Color: ${car['color']}',
                                style: TextStyle(fontSize: 12),
                              ),

                              SizedBox(height: 5),
                              Text(
                                'Price per day: ${car['price_per_day'] != null ? '${car['price_per_day']} \Rs' : 'Unknown'}',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditVehicleScreen(car: car),
                                        ),
                                      );
                                    },
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(context, car);
                                    },
                                  ),
                                ],
                              ),
                            ],
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
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot car) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion', style: TextStyle(color: Colors.red)),
          content: Text(
            'Are you sure you want to delete this Vehicle?',
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                _deleteCar(context, car);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteCar(BuildContext context, DocumentSnapshot car) {
    try {
      FirebaseFirestore.instance.collection('bus').doc(car.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bike Deleted')));
    } catch (error) {
      print('Error deleting Bike: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete Bike')));
    }
  }
}
