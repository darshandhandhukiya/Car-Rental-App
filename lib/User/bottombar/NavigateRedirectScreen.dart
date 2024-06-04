


import 'package:flutter/material.dart';





import '../booked_Car/BookedCarScreen.dart';
import '../home/HomePage.dart';
import '../profile/Profile.dart';
import '../wishlist/wishlist.dart';


// Define a class to represent a car



class NavigateRedirectScreen extends StatefulWidget {
  const NavigateRedirectScreen({Key? key}) : super(key: key);

  @override
  State<NavigateRedirectScreen> createState() => _NavigateRedirectScreenState();
}

class _NavigateRedirectScreenState extends State<NavigateRedirectScreen> {

  int currentPageIndex = 0;
  List screens = [
    HomeScreenn(),
    WishlistScreen(),
    UserBookingsScreen(),
    ImageUploads()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmark),
            icon: Icon(Icons.bookmark_outline),
            label: 'MyBooking',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
