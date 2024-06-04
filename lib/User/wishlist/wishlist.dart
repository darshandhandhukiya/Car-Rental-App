import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/fulldetail.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late String userId;
  late Stream<QuerySnapshot> wishlistStream;

  @override
  void initState() {
    super.initState();
    // Get the current user ID
    userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the wishlist data for the current user
    wishlistStream = FirebaseFirestore.instance
        .collection('wishlist')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> _removeFromWishlist(String docId) async {
    try {
      // Remove the item from the wishlist using its document ID
      await FirebaseFirestore.instance.collection('wishlist').doc(docId).delete();
    } catch (error) {
      print('Error removing item from wishlist: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: StreamBuilder(
        stream: wishlistStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Wishlist is empty.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              List<String> carImages = List<String>.from(doc['carImage']);
              // Get the first image URL
              String firstImage = carImages.isNotEmpty ? carImages[0] : '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Fulldetail(
                        carName: doc['carName'],
                        carImages: carImages, // Pass list of car images
                        carColor: doc['carColor'],
                        carDetail: doc['carDetail'],
                        carRent: doc['carRent'],
                        carModel: doc['carModel'],
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(firstImage),
                    ),
                    title: Text(doc['carName']),
                    subtitle: Text('Price: ${doc['carRent']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFromWishlist(doc.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
