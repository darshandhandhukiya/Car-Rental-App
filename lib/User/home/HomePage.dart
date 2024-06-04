import 'package:cab_ex/User/home/pending_req_screen.dart';
import 'package:cab_ex/User/home/search.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'fulldetail.dart';


class HomeScreenn extends StatefulWidget {
  @override
  _HomeScreennState createState() => _HomeScreennState();
}

class _HomeScreennState extends State<HomeScreenn> {
  CarouselController carouselController = CarouselController();
  List<String> wishlist = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EasyRide ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => search()));
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PendingRequestsScreen()));
            },
            icon: Icon(Icons.pending,color: Colors.red,),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome to EasyRide",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: "Search here",
                      ),
                    ),
                    SizedBox(height: 10),
                    CarouselSlider(
                      items: [
                        Image.asset("assets/images/slide1.jpg"),
                        Image.asset("assets/images/slide2.jpg"),
                        Image.asset("assets/images/Your paragraph text.jpg"),
                      ],
                      carouselController: carouselController,
                      options: CarouselOptions(
                        viewportFraction: 1.2,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayInterval: Duration(seconds: 2),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Ride with Cars',
                          style: GoogleFonts.cabin(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      ],
                    ),
                    SizedBox(
                      height: 195,
                      child: _buildCarListView(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Ride with Bus',
                          style: GoogleFonts.cabin(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text("See All"),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 195,
                      child: _buildBusListView(),
                    ),

                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Ride with Bike',
                          style: GoogleFonts.cabin(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text("See All"),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 195,
                      child: _buildBikeListView(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarListView() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('car').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No cars available'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot car = snapshot.data!.docs[index];
            List<String> carImages = List<String>.from(car['car_images']);
            String firstImage = carImages.isNotEmpty ? carImages[0] : '';

            return _buildCarItem(firstImage, car);
          },
        );
      },
    );
  }

  Widget _buildBusListView() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('bus').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No buses available'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot bus = snapshot.data!.docs[index];
            List<String> busImages = List<String>.from(bus['car_images']);
            String firstImage = busImages.isNotEmpty ? busImages[0] : '';

            return _buildBusItem(firstImage, bus);
          },
        );
      },
    );
  }

  Widget _buildBikeListView() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('bike').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No cars available'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot bike = snapshot.data!.docs[index];
            List<String> carImages = List<String>.from(bike['car_images']);
            String firstImage = carImages.isNotEmpty ? carImages[0] : '';

            return _buildBikeItem(firstImage, bike);
          },
        );
      },
    );
  }


  Widget _buildCarItem(String firstImage, DocumentSnapshot car) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Fulldetail(
                carName: car['car_name'],
                carImages: List<String>.from(car['car_images']),
                carColor: car['color'],
                carDetail: car['detail'],
                carRent: car['price_per_day'].toInt(),
                carModel: car['car_model'],
              ),
            ),
          );
        },
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(firstImage),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(car['car_name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text("Price per day"+
                  car['price_per_day'].toInt().toString(),
                  style: TextStyle(fontSize: 12, ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusItem(String firstImage, DocumentSnapshot bus) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Fulldetail(
                carName: bus['car_name'],
                carImages: List<String>.from(bus['car_images']),
                carColor: bus['color'],
                carDetail: bus['detail'],
                carRent: bus['price_per_day'],
                carModel: bus['car_model'],
              ),
            ),
          );
        },
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(firstImage),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  bus['car_name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text("Price per day"+
                    bus['price_per_day'].toInt().toString(),
                  style: TextStyle(fontSize: 12, ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBikeItem(String firstImage, DocumentSnapshot bike) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Fulldetail(
                carName: bike['car_name'],
                carImages: List<String>.from(bike['car_images']),
                carColor: bike['color'],
                carDetail: bike['detail'],
                carRent: bike['price_per_day'],
                carModel: bike['car_model'],
              ),
            ),
          );
        },
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(firstImage),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  bike['car_name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

}
