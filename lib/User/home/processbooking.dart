import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProcessBookingScreen extends StatefulWidget {
  final String carName;
  final num carRent;
  final DateTimeRange selectedDateRange;
  final num totalPayment;

  ProcessBookingScreen({
    required this.carName,
    required this.carRent,
    required this.selectedDateRange,
    required this.totalPayment,
  });

  @override
  _ProcessBookingScreenState createState() => _ProcessBookingScreenState();
}

class _ProcessBookingScreenState extends State<ProcessBookingScreen> {
  Razorpay? _razorpay = Razorpay();
  String adminResponse = '';
  bool canMakePayment = false;

  @override
  void initState() {
    super.initState();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _listenToAdminResponse();
  }

  @override
  void dispose() {
    _razorpay!.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {

    String paymentId = response.paymentId ?? '';
    Fluttertoast.showToast(
      msg: "SUCCESS PAYMENT: $paymentId",
      timeInSecForIosWeb: 10,
    );

    // store data in firebase
    _storeBookingDetails();


    _storePaymentDetails(paymentId);
  }

  void _storeBookingDetails() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      int numberOfDays = widget.selectedDateRange.end
          .difference(widget.selectedDateRange.start)
          .inDays  ;
      num calculatedPayment = numberOfDays * widget.carRent ;
      num discount = numberOfDays >= 30 ? calculatedPayment * 0.10 : 0;
      num finalPayment = calculatedPayment - discount ;

      DateTime currentDate = DateTime.now();
      DateTime startDate = widget.selectedDateRange.start;
      DateTime endDate = widget.selectedDateRange.end;
      String status = '';

      if (currentDate.isBefore(startDate)) {
        status = 'Booking Pending';
      } else if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
        status = 'Booking Currently';
      } else {
        status = 'Ride Completed';
      }

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': userId,
        'carName': widget.carName,
        'startDate': startDate,
        'endDate': endDate,
        'numberOfDays': numberOfDays,
        'pricePerDay': widget.carRent,
        'discount': discount,
        'totalPayment': finalPayment + widget.carRent,
        'status': status,

      });
    } catch (error) {
      print("Error storing booking details: $error");

    }
  }


  void _storePaymentDetails(String paymentId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String userName = await _getCurrentUserName();


      await FirebaseFirestore.instance.collection('payments').add({
        'userId': userId,
        'userName': userName,
        'paymentId': paymentId,
        'totalPayment': widget.totalPayment,

      });
    } catch (error) {
      print("Error storing payment details: $error");

    }
  }





  void _handlePaymentError(PaymentFailureResponse response) {

    Fluttertoast.showToast(
      msg: "ERROR HERE: ${response.code} - ${response.message}",
      timeInSecForIosWeb: 4,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {

    Fluttertoast.showToast(
      msg: "EXTERNAL_WALLET IS : ${response.walletName}",
      timeInSecForIosWeb: 4,
    );
  }

  void openPaymentPortal() async {

    var options = {
      'key': 'rzp_test_l0NWKg66UwdF9J',
      'amount': widget.totalPayment * 100 + widget.carRent * 100 ,
      'name': 'EasyRide Rental',
      'description': 'Payment',
      'prefill': {'contact': '9262762662', 'email': 'yash@gmail.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget build(BuildContext context) {
    int numberOfDays = widget.selectedDateRange.end
        .difference(widget.selectedDateRange.start)
        .inDays +
        1;
    num calculatedPayment = numberOfDays * widget.carRent;
    bool applyDiscount = numberOfDays >= 30;
    num discount = applyDiscount ? calculatedPayment * 0.10 : 0;
    num finalPayment = applyDiscount
        ? calculatedPayment - discount
        : calculatedPayment;

    return FutureBuilder(
      future: _getCurrentUserName(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Booking Details',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(color: Colors.white),
                ),
              ),
              backgroundColor: Colors.black87,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        String userName = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Bookings Information',
              style: GoogleFonts.lato(
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
            backgroundColor: Colors.black87,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Customer Name: $userName',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vehicle Name: ${widget.carName}',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Selected Dates: ${widget.selectedDateRange.start.toString().substring(0, 10)} to ${widget.selectedDateRange.end.toString().substring(0, 10)}',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Number of Days: $numberOfDays',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Price per Day: ${widget.carRent}',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 15),
                      ),
                    ),
                    if (applyDiscount) // Display discount only if applicable
                      SizedBox(height: 8),
                    Text(
                      'Discount (10% off on Monthly booking): -$discount',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Text(
                      'Total Payment: $finalPayment',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          // Tap on PROCESS NOW
                          await _sendRequestToAdmin(
                              await _getCurrentUserId(), userName);
                          Fluttertoast.showToast(
                            msg: "Request sent to admin for availability check",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.black87,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Check Availability',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Displaying status from admin_requests collection
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('admin_requests')
                          .where('userId', )
                          .orderBy('timestamp', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No status available');
                        }
                        String status = snapshot.data!.docs.first['status'];
                        return Column(
                          children: [
                            Center(
                              child: ElevatedButton(
                                onPressed: status == 'Accepted' ? openPaymentPortal : null,
                                child: Text('Pay Now'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.disabled)) {
                                        // Disable color
                                        return Colors.redAccent;
                                      }
                                      // Enable color
                                      return Colors.greenAccent;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Current Status: $status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ],
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }




  _listenToAdminResponse() {
    FirebaseFirestore.instance
        .collection('admin_requests')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        String status = snapshot.docs.first['status'];
        setState(() {
          canMakePayment = status == 'Accepted';
        });
      }
    });
  }

  Future<String> _getCurrentUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  Future<String> _getCurrentUserName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userSnapshot.exists) {
        return userSnapshot['Username'] ?? 'Unknown';
      }
    }
    return 'wait';
  }

  Future<void> _sendRequestToAdmin(String userId, String userName) async {
    QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: 'admin@gmail.com')
        .limit(1)
        .get();

    if (adminSnapshot.docs.isNotEmpty) {
      String adminId = adminSnapshot.docs.first.id;

      await FirebaseFirestore.instance.collection('admin_requests').add({
        'userId': userId,
        'userName': userName,
        'carName': widget.carName,
        'startDate': widget.selectedDateRange.start,
        'endDate': widget.selectedDateRange.end,
        'totalPayment': widget.totalPayment + widget.carRent,
        'status': 'Pending', // Initial status set to 'Pending'
        'timestamp': DateTime.now(),
      });
    }
  }
}
