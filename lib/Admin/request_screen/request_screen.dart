import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AdminRequestsScreen extends StatelessWidget {
  static int pendingRequestsCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('admin_requests').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No booking requests found.'));
          }

          int pendingCount = snapshot.data!.docs.where((doc) => doc['status'] == 'Pending').length;
          AdminRequestsScreen.pendingRequestsCount = pendingCount;

          //toast for request
          if (!snapshot.data!.docChanges.isEmpty) {
            Fluttertoast.showToast(
              msg: 'New booking request arrived!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot request = snapshot.data!.docs[index];
              return _buildRequestTile(context, request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestTile(BuildContext context, DocumentSnapshot request) {
    Color tileColor = Colors.white;
    IconData iconData;
    Color iconColor;


    if (request['status'] == 'Accepted') {
      iconData = Icons.check;
      iconColor = Colors.green;
      tileColor = Colors.green[50]!;
    } else if (request['status'] == 'Rejected') {
      iconData = Icons.close;
      iconColor = Colors.red;
      tileColor = Colors.red[50]!;
    } else {
      // Default state when request status is pending
      iconData = Icons.pending_actions;
      iconColor = Colors.grey;
    }

    bool isNewRequest = !request.metadata.isFromCache && !request.metadata.hasPendingWrites;


    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
        child: Dismissible(
          key: Key(request.id),
          background: Container(
            color: Colors.red[200],
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await _confirmDelete(context);
          },
          onDismissed: (direction) async {
            await request.reference.delete();
          },
          child: ListTile(

            title: Text('Is this Available ? ',style: TextStyle(color: Colors.red),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User ID: ${request['userId']}'),
                Text('Car Name: ${request['carName']}'),
                Text('Selected Dates: ${_formatDate(request['startDate'])} to ${_formatDate(request['endDate'])}'),
                Text('Total Payment: ${request['totalPayment']}'),
                Text('Availability: ${request['status']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 1),),
              ],
            ),
            trailing: Icon(
              iconData,
              color: Colors.black,
            ),
            tileColor: tileColor,
            onTap: () => _respondToRequest(context, request, request['status'] == 'Pending'),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to delete this request?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("DELETE"),
            ),
          ],
        );
      },
    );
  }

  void _respondToRequest(BuildContext context, DocumentSnapshot request, bool accept) async {
    String status = accept ? 'Accepted' : 'Rejected';
    try {
      // Update booking status in the 'admin_requests' collection
      await request.reference.update({
        'status': status,
      });

      // If the request is accepted, you may want to perform additional actions,
      // such as notifying the user or updating other related documents.

      // Example: Sending response to the user
      if (true) {
        String userId = request['userId'];
        await FirebaseFirestore.instance.collection('admin_requests').doc(request.id).update({
          'bookingStatus': status,
        });
      }
    } catch (error) {
      // Handle errors
      print("Error responding to request: $error");
    }
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }



}
