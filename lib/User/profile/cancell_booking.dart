import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CanceledBookingsScreen extends StatelessWidget {
  // Initialize FirebaseAuth and FirebaseFirestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _auth.authStateChanges().first,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Canceled Bookings'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (userSnapshot.hasError) {
          // Display error message if any
          return Scaffold(
            appBar: AppBar(
              title: Text('Canceled Bookings'),
            ),
            body: Center(
              child: Text('Error occurred. Please try again.'),
            ),
          );
        } else {
          User? currentUser = userSnapshot.data;
          if (currentUser == null) {
            // User not logged in
            return Scaffold(
              appBar: AppBar(
                title: Text('Canceled Bookings'),
              ),
              body: Center(
                child: Text('User not logged in.'),
              ),
            );
          } else {
            // User logged in, fetch and display canceled bookings
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('bookingcancel')
                  .where('userId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('No Cancelled Bookings'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No canceled bookings found.'));
                } else {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text('Canceled Bookings'),
                    ),
                    body: ListView(
                      children: snapshot.data!.docs.map((document) {
                        Map<String, dynamic> data = document.data()!;
                        // Fetch cancelDate
                        DateTime cancelDate = data['cancelDate'].toDate();

                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: ListTile(
                            title: Text(
                              data['carName'],
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  'Start Date: ${data['startDate'].toDate()}',
                                  style: GoogleFonts.lato(),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'End Date: ${data['endDate'].toDate()}',
                                  style: GoogleFonts.lato(),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Total Payment: Rs ${data['totalPayment']}',
                                  style: GoogleFonts.lato(),
                                ),
                                SizedBox(height: 4),
                                // Display cancelDate
                                Text(
                                  'Cancel Date: $cancelDate',
                                  style: GoogleFonts.lato(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            );
          }
        }
      },
    );
  }
}
