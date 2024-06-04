import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllUsersRatingDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Users Rating Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('ratings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ratingDocs = snapshot.data?.docs;

          if (ratingDocs == null || ratingDocs.isEmpty) {
            return Center(child: Text('No rating details found for any user.'));
          }

          return ListView.builder(
            itemCount: ratingDocs.length,
            itemBuilder: (context, index) {
              final ratingDetails = ratingDocs[index].data();
              final ratingId = ratingDocs[index].id;
              final userId = ratingDetails['userId']; // Assuming userId is stored in the rating document

              // Determine color based on rating
              Color color;
              if (ratingDetails['rating'] == 3) {
                color = Colors.green.shade600; // Shadow green for rating 3
              } else if (ratingDetails['rating'] == 2) {
                color = Colors.yellow.shade600; // Yellow shade for rating 2
              } else {
                color = Colors.red.shade600; // Red shade for other ratings
              }

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(); // Placeholder widget while waiting for user details
                  }

                  if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  }

                  final userData = userSnapshot.data?.data();
                  final username = '${userData?['First_name']} ${userData?['Last name']}';

                  return Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User ID: $userId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Username: $username', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Rating: ${ratingDetails['rating']}', style: TextStyle(fontSize: 16, color: color)),
                        SizedBox(height: 10),
                        Text('Description: ${ratingDetails['description']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Timestamp: ${_formatTimestamp(ratingDetails['timestamp'])}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _showDeleteDialog(context, ratingId),
                          child: Text('Delete'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(color),
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  Future<void> _showDeleteDialog(BuildContext context, String ratingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this rating?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('ratings').doc(ratingId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
