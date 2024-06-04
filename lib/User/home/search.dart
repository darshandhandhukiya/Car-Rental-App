import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';


class search extends StatefulWidget {
  const search({super.key});

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {

  TextEditingController searchcontroller = TextEditingController();
  List allResult = [];
  List resultList = [];

  void getData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection("car")
        .orderBy("car_name")
        .get();
    var snapshot1 = await FirebaseFirestore.instance
        .collection("bus")
        .orderBy("car_name")
        .get();
    var snapshot2 = await FirebaseFirestore.instance
        .collection("bike")
        .orderBy("car_name")
        .get();

    setState(() {
      allResult.addAll(snapshot.docs);
      allResult.addAll(snapshot1.docs);
      allResult.addAll(snapshot2.docs);

    });
    searchData();
  }
  void searchData() {
    List showResult = [];
    if (searchcontroller.text != "") {
      for (var data in allResult) {
        var courseName = data['car_name'].toString().toLowerCase();
        if (courseName.contains(searchcontroller.text.toLowerCase())) {
          showResult.add(data);
        }
      }
    } else {
      showResult = List.from(allResult);

      // ignore: avoid_print
      print(showResult);
    }
    setState(() {

      resultList = showResult;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: searchcontroller,
                onChanged: (query){
                  searchData();
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  hintText: 'Search',
                ),
                autofocus: true,
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("car").snapshots()
              ,builder: (context, snapshot) {
              if(snapshot.hasError)
              {
                return Center(child: Text(snapshot.error.toString()),);
              }
              else if(snapshot.hasData)
              {
                QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;

                List<QueryDocumentSnapshot<Map<String, dynamic>>> alldata = data!.docs;
                return    Expanded(
                  child: GridView.count(crossAxisCount: 2,
                    mainAxisSpacing: 9,
                    childAspectRatio: 0.95 ,
                    crossAxisSpacing: 9,
                    children: resultList.map((e) => Padding(
                      padding: EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          // Navigate to another screen or perform an action
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 1,
                                offset: Offset(2, 3),
                                spreadRadius: 0.2,
                                blurStyle: BlurStyle.normal,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                ),
                                child: Image.network(
                                  e['car_images'][0], // Accessing the first image URL
                                  height: 100,
                                  width: 200,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    e['car_name'], // Accessing the first car name
                                    style: GoogleFonts.abrilFatface(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    e['price_per_day'].toStringAsFixed(2), // Convert double to string
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                    ),).toList(),
                  ),
                );
              }
              return Center(child: CircularProgressIndicator(),);
            },),
          ],
        ),
      ),
    );
  }
}