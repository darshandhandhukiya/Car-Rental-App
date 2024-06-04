import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'add_bike.dart';
import 'add_large_vehicle.dart';
import 'car_detail_screen.dart';

class UploadVehicleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Vehicle'),
      ),
      body: ListView(
        children: [
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CarImageUploadScreen()));
              },
              child: _buildOption(context, 'Add Car', Icons.directions_car, Colors.blue, '/add_car')),
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LargeImageUploadScreen()));
              },
              child: _buildOption(context, 'Add Tour Vehicle', Icons.bus_alert, Colors.green, '/add_tour_vehicle')),
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>BikeImageUploadScreen()));
              },
          child:_buildOption(context, 'Add Bike', Icons.directions_bike, Colors.orange, '/add_bike')),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon, Color color, String route) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 50,
            color: color,
          ),
          SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
