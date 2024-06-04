import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingScreen extends StatefulWidget {
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedRating = 0;
  String _ratingDescription = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRating();
  }

  Future<void> _fetchUserRating() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> userRating = await FirebaseFirestore.instance
          .collection('ratings')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();

      if (userRating.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> ratingDoc = userRating.docs.first;
        setState(() {
          _selectedRating = ratingDoc['rating'];
          _ratingDescription = ratingDoc['description'];
        });
      }
    } catch (error) {
      print('Error fetching user rating: $error');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Us',),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please give your rating:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStar(1),
                _buildStar(2),
                _buildStar(3),
              ],
            ),
            SizedBox(height: 20),
            Text(
              _ratingDescription.isNotEmpty ? '$_ratingDescription' : '',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedRating != 0 ? _submitRating : null,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(int value) {
    return IconButton(
      onPressed: () {
        setState(() {
          _selectedRating = value;
          _updateRatingDescription();
        });
      },
      icon: Icon(
        value <= _selectedRating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 40,
      ),
    );
  }

  void _updateRatingDescription() {
    switch (_selectedRating) {
      case 1:
        _ratingDescription = 'Rating: Not Good';
        break;
      case 2:
        _ratingDescription = 'Rating: Good';
        break;
      case 3:
        _ratingDescription = 'Rating: Excellence';
        break;
      default:
        _ratingDescription = '';
    }
  }

  void _submitRating() async {
    try {
      // Check if the user has already given a rating
      final QuerySnapshot<Map<String, dynamic>> existingRating = await FirebaseFirestore.instance
          .collection('ratings')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // If a rating exists, update it
        final DocumentSnapshot<Map<String, dynamic>> ratingDoc = existingRating.docs.first;
        await ratingDoc.reference.update({
          'rating': _selectedRating,
          'description': _ratingDescription,
          'timestamp': Timestamp.now(),
        });
      } else {
        // If no rating exists, add a new one
        await FirebaseFirestore.instance.collection('ratings').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'rating': _selectedRating,
          'description': _ratingDescription,
          'timestamp': Timestamp.now(),
        });
      }

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating submitted successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reset the selected rating
      setState(() {
        _selectedRating = 0;
        _ratingDescription = '';
      });
    } catch (error) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit rating'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

}
