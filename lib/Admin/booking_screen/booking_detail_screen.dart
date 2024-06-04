import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot booking = snapshot.data!.docs[index];
              return _buildBookingTile(booking, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingTile(DocumentSnapshot booking, BuildContext context) {
    return Dismissible(
      key: Key(booking.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm"),
              content: Text("Are you sure you want to delete this booking?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteBooking(booking.id);
      },
      child: _buildBookingContent(booking),
    );
  }

  Widget _buildBookingContent(DocumentSnapshot booking) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(booking['userId']).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Loading...'),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return ListTile(
            title: Text('User ID: ${booking['userId']}'), // Display user ID
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildBookingDetails(booking),
            ),
          );
        }

        String username = userSnapshot.data!['Username'] ?? 'Unknown';
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text('Customer Name: $username'), // Display username
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildBookingDetails(booking),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBookingDetails(DocumentSnapshot booking) {
    // Convert Firestore Timestamp to String format
    String startDate = _formatDate(booking['startDate']);
    String endDate = _formatDate(booking['endDate']);

    return [
      Text('Car Name: ${booking['carName']}'),
      Text('Start Date: $startDate'),
      Text('End Date: $endDate'),
      Text('Discount: ${booking['discount']}'),
      Text('Price per Day: ${booking['pricePerDay']} Rs'),
      Text('Total Payment: ${booking['totalPayment']} Rs'),
    ];
  }

  String _formatDate(Timestamp timestamp) {
    // Convert Firestore Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();
    // Format DateTime to desired String format
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }

  void _deleteBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();
      print('Booking deleted successfully');
    } catch (error) {
      print('Error deleting booking: $error');
    }
  }
}
