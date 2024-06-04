import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserBookingsScreen extends StatelessWidget {
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
              title: Text('Your Bookings'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (userSnapshot.hasError) {
          // Display error message if any
          return Scaffold(
            appBar: AppBar(
              title: Text('My Bookings'),
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
                title: Text('My Bookings'),
              ),
              body: Center(
                child: Text('User not logged in.'),
              ),
            );
          } else {

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('bookings')
                  .where('userId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No bookings found.'));
                } else {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text('My Bookings'),
                    ),
                    body: ListView(
                      children: snapshot.data!.docs.map((document) {
                        Map<String, dynamic> data = document.data()!;
                        String status = data['status'];

                        // Check if the booking status is 'Booking Pending'
                        bool isBookingPending = status == 'Booking Pending';

                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
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
                                  status,
                                  style: GoogleFonts.lato(),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'End Date: ${data['endDate'].toDate()}',
                                  style: GoogleFonts.lato(),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Total Payment: \Rs ${data['totalPayment']}',
                                  style: GoogleFonts.lato(),
                                ),
                              ],
                            ),
                            trailing: isBookingPending
                                ? ElevatedButton(
                              onPressed: () {
                                // Cancel booking and store in 'bookingcancel' collection
                                _cancelBooking(document.id, context);
                              },

                              child: Text('Cancel'),
                            )
                                : null,
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

  Future<void> _cancelBooking(String bookingId, BuildContext context) async {
    try {
      DocumentSnapshot bookingSnapshot =
      await _firestore.collection('bookings').doc(bookingId).get();

      if (bookingSnapshot.exists) {
        Map<String, dynamic>? bookingData =
        bookingSnapshot.data() as Map<String, dynamic>?;

        if (bookingData != null) {
          String? status = bookingData['status'];

          if (status == 'Booking Pending') {
            // Store the current date as the cancel date
            DateTime cancelDate = DateTime.now();
            bookingData['cancelDate'] = cancelDate;

            // Store the booking details in 'bookingcancel' collection
            await _firestore.collection('bookingcancel').add(bookingData);

            // Delete the booking from 'bookings' collection
            await _firestore.collection('bookings').doc(bookingId).delete();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking canceled successfully.'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Cannot cancel booking. Status is not "Booking Pending".'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: Booking data is null.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Booking does not exist.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error canceling booking: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

//
  // Future<void> _cancelBooking(String bookingId, BuildContext context) async {
  //   try {
  //     // Get the booking document
  //     DocumentSnapshot bookingSnapshot =
  //     await _firestore.collection('bookings').doc(bookingId).get();
  //
  //     // Check if the booking exists and status is 'Booking Pending'
  //     if (bookingSnapshot.exists) {
  //       Map<String, dynamic>? bookingData =
  //       bookingSnapshot.data() as Map<String, dynamic>?; // Explicit cast
  //
  //       if (bookingData != null) {
  //         String status = bookingData['status'];
  //         if (status == 'Booking Pending') {
  //           // Store the booking details in 'bookingcancel' collection
  //           await _firestore.collection('bookingcancel').add(bookingData);
  //
  //           // Delete the booking from 'bookings' collection
  //           await _firestore.collection('bookings').doc(bookingId).delete();
  //
  //           // Show success message
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Booking canceled successfully.'),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //         } else {
  //           // Show error message if the booking status is not 'Booking Pending'
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Cannot cancel booking. Status is not "Booking Pending".'),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //       } else {
  //         // Show error message if booking data is null
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Error: Booking data is null.'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     } else {
  //       // Show error message if the booking does not exist
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: Booking does not exist.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error canceling booking: $error'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }


}
