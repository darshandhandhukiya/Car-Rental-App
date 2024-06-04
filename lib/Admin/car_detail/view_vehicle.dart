import 'package:cab_ex/Admin/car_detail/view_bike.dart';
import 'package:cab_ex/Admin/car_detail/view_car_detail.dart';
import 'package:cab_ex/Admin/car_detail/view_tour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class ViewVehicleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Vehicle'),
      ),
      body: ListView(
        children: [
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CarScreen()));
              },
              child: _buildOption(context, 'View Cars', Icons.directions_car, Colors.blue, '/add_car')),
          GestureDetector(
              onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (context)=>TourVehicleScreen()));
              },
              child: _buildOption(context, 'View Tour Vehicle', Icons.bus_alert, Colors.green, '/add_tour_vehicle')),
          GestureDetector(
              onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>BikeViewScreen()));
              },
              child:_buildOption(context, 'View Bike', Icons.directions_bike, Colors.orange, '/add_bike')),
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
