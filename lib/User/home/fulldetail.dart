
import 'package:cab_ex/User/home/processbooking.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Fulldetail extends StatefulWidget {
  final String carName;
  final List<String> carImages;
  final String carColor;
  final String carDetail;
  final num carRent;
  final String carModel;

  Fulldetail({
    required this.carName,
    required this.carImages,
    required this.carColor,
    required this.carDetail,
    required this.carRent,
    required this.carModel,
  });

  @override
  _FulldetailState createState() => _FulldetailState();
}

class _FulldetailState extends State<Fulldetail> {
  DateTimeRange? _selectedDateRange;
  bool _isAddedToWishlist = false;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }


  void _processBooking(BuildContext context) {
    // Calculate total payment
    if (_selectedDateRange != null) {
      int numberOfDays = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays;
      num totalPayment = widget.carRent * numberOfDays;


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessBookingScreen(
            carName: widget.carName,
            carRent: widget.carRent,
            selectedDateRange: _selectedDateRange!,
            totalPayment: totalPayment,
          ),
        ),
      );
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date range.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> _addToWishlist() async {
    try {

      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('wishlist').add({
        'userId': userId,
        'carName': widget.carName,
        'carImage': widget.carImages,
        'carColor': widget.carColor,
        'carDetail': widget.carDetail,
        'carRent': widget.carRent,
        'carModel': widget.carModel,
      });

      setState(() {
        _isAddedToWishlist = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to Wishlist'),
        ),
      );
    } catch (error) {

      print('Error adding to wishlist: $error');


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to Wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isAddedToWishlist ? Icons.favorite : Icons.favorite_border,
              color: _isAddedToWishlist ? Colors.red : null,
            ),
            onPressed: _addToWishlist,
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    '${widget.carName}',
                    style: GoogleFonts.inknutAntiqua(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                 child:  CarouselSlider(
                   items: widget.carImages.map<Widget>((imageUrl) {
                     return Image.network(
                       imageUrl,
                       fit: BoxFit.cover,
                     );
                   }).toList(),
                   options: CarouselOptions(
                     height: 200,
                     viewportFraction: 1,
                     aspectRatio: 16 / 9,
                     autoPlayInterval: Duration(seconds: 2),
                     autoPlayAnimationDuration: Duration(milliseconds: 800),
                     autoPlayCurve: Curves.fastOutSlowIn,
                   ),
                 ),
                ),
              ],
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
            ),
            Positioned(
              top: 250,
              left: 40,
              child: Container(
                height: 250,
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 1,
                      offset: Offset(2, 3),
                      spreadRadius: 0.2,
                      blurStyle: BlurStyle.normal,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.carColor}',
                        style: GoogleFonts.inknutAntiqua(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        '${widget.carDetail}',
                        style: GoogleFonts.inknutAntiqua(
                          textStyle: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        '${widget.carModel}',
                        style: GoogleFonts.inknutAntiqua(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        'Price per Day: ${widget.carRent}',
                        style: GoogleFonts.inknutAntiqua(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 520,
              left: 25,
              child: Container(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        height: 40,
                        width: 320,
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 1,
                                offset: Offset(2, 3),
                                spreadRadius: 0.2,
                                blurStyle: BlurStyle.normal,
                              )
                            ]
                        ),
                        child: Center(
                          child: Text(
                            'Select Date: ${_selectedDateRange?.start?.toString().substring(0, 10) ?? ''} to ${_selectedDateRange?.end?.toString().substring(0, 10) ?? ''}',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () => _processBooking(context),
                      child: Container(
                        height: 40,
                        width: 270,
                        decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 1,
                                offset: Offset(2, 3),
                                spreadRadius: 0.2,
                                blurStyle: BlurStyle.normal,
                              )
                            ]
                        ),
                        child: Center(child: Text("Process Now",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
