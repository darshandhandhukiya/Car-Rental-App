import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cab_ex/User/home/processbooking.dart';

class PendingRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('admin_requests')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No pending requests.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot request = snapshot.data!.docs[index];
              return _buildRequestCard(request, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(DocumentSnapshot request, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessBookingScreen(
            carName: request['carName'],
            carRent: request['totalPayment'],
            selectedDateRange: DateTimeRange(
              start: request['startDate'].toDate(),
              end: request['endDate'].toDate(),
            ),
            totalPayment: request['totalPayment'],
          ),
        ),
      ),
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Car: ${request['carName']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Dates: ${_formatDate(request['startDate'])} - ${_formatDate(request['endDate'])}'),
              SizedBox(height: 8),
              Text('Total Payment: Rs ${request['totalPayment']}'),
              SizedBox(height: 8),
              Text('Status: ${request['status']}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _deleteRequest(request.id, context),
                child: Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );

  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }

  Future<void> _deleteRequest(String requestId, BuildContext context) async { // Add BuildContext parameter
    try {
      await FirebaseFirestore.instance.collection('admin_requests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Request deleted successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete request'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}
