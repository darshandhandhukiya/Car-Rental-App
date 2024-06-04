import 'package:cab_ex/Admin/booking_screen/option_booking.dart';
import 'package:cab_ex/Admin/car_detail/view_vehicle.dart';
import 'package:cab_ex/Admin/screen/user_info_screen.dart';
import 'package:cab_ex/Admin/car_detail/view_car_detail.dart';
import 'package:cab_ex/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../add_car_screen/add_large_vehicle.dart';
import '../add_car_screen/add_vehicles.dart';
import '../booking_screen/booking_detail_screen.dart';
import '../add_car_screen/car_detail_screen.dart';
import '../booking_screen/cancelled_screen.dart';
import '../manage_rating.dart';
import '../request_screen/request_screen.dart';
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _pendingRequestsStream;

  @override
  void initState() {
    super.initState();
    _setupPendingRequestsStream();
  }

  void _setupPendingRequestsStream() {
    _pendingRequestsStream = FirebaseFirestore.instance
        .collection('admin_requests')
        .where('status', isEqualTo: 'Pending')
        .snapshots();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       leading: IconButton(
         icon: Icon(Icons.logout),
         onPressed: () {
           _showLogoutConfirmationDialog();

         },
       ),

       title: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _pendingRequestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Dashboard');
        } else {
          int pendingCount = snapshot.data?.docs.length ?? 0;
          return _buildAppBarTitle(pendingCount);
        }
      },
      ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContainer(
                    gradientColors: [Colors.purple, Colors.deepPurple],
                    icon: Icons.person,
                    label: 'User Information',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserInformationScreen()),
                      );
                    },
                  ),
                  _buildContainer(
                    gradientColors: [Colors.orange, Colors.deepOrange],
                    icon: Icons.book,
                    label: 'Booking Detail',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OptionBook()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContainer(
                    gradientColors: [Colors.blue, Colors.lightBlue],
                    icon: Icons.directions_car,
                    label: 'Vehicle Detail',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewVehicleScreen()),
                      );
                    },
                  ),
                  _buildContainer(
                    gradientColors: [Colors.green, Colors.teal],
                    icon: Icons.add_circle,
                    label: 'Add Vehicle',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadVehicleScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContainer(
                    gradientColors: [Colors.redAccent, Colors.orange],
                    icon: Icons.request_page,
                    label: 'Booking Requests',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminRequestsScreen()),
                      );
                    },
                  ),
                  _buildContainer(
                    gradientColors: [Colors.indigo, Colors.blue],
                    icon: Icons.cancel,
                    label: 'Manage Rating',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllUsersRatingDetailsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer({
    required List<Color> gradientColors,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(int pendingCount) {
    if (pendingCount > 0) {
      return Row(
        children: [
          Text('Dashboard'),
          SizedBox(width: 70),
          Text('Request',style: TextStyle(fontSize: 16),),

          SizedBox(width: 10),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminRequestsScreen()));
            },
            child: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                pendingCount.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else {
      return Text('Dashboard');
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _logout(); // Call the logout method if confirmed
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => login()),
            (route) => false, // This will clear the navigation stack
      );
    } catch (error) {
      print("Error logging out: $error");
      // Handle any errors that occur during logout
    }
  }
}

