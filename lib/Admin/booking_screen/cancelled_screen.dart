import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingCancelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canceled Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('bookingcancel').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No canceled bookings found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot booking = snapshot.data!.docs[index];
              return _buildBookingTile(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingTile(BuildContext context, DocumentSnapshot booking) {
    String userId = booking['userId'];
    String carName = booking['carName'];
    Timestamp startDate = booking['startDate'];
    Timestamp endDate = booking['endDate'];
    Timestamp cancelDate = booking['cancelDate'];

    // Fetch user's name from Firestore using userId
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Loading...'),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return ListTile(
            title: Text('User not found'),
          );
        }

        String userName = userSnapshot.data!['First_name'];

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              'User: $userName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Car Name: $carName'),
                Text('Start Date: ${startDate.toDate()}'),
                Text('End Date: ${endDate.toDate()}'),
                Text('Cancel Date: ${cancelDate.toDate()}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
