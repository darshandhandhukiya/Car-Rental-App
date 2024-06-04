
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class registration extends StatefulWidget {
  const registration({super.key});

  @override
  State<registration> createState() => _registrationState();
}

class _registrationState extends State<registration> {
  final _formkey = GlobalKey<FormState>();
  final fnamecontoller = TextEditingController();
  final lnamecontroller = TextEditingController();
  final mobilenocontroller = TextEditingController();
  final emailaddcontoller = TextEditingController();
  final passwdcontroller = TextEditingController();
  bool passToogle = true;

  String fname = "";
  String lname = "";
  String mono = "";
  String email = "";
  String password = "";

  signup(String email, String password, String fname, String lname,
      String mono) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String userId = userCredential.user!.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'Username': '',
        'First_name': fname,
        'Last name': lname,
        'mobile_no': mono,
        'email': email,
        'profile_image': '',

      });

      print('Registration successful');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        const SnackBar(
            backgroundColor: Colors.grey,
            content: Text('The account already exists with this Email'));
      } else {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(

          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              // physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 20,),
                 Container(
                   height: 280,
                   decoration:  BoxDecoration(
                     image: DecorationImage(
                       image: AssetImage("assets/logo1.png"),
                       fit: BoxFit.fill,
                     ),
                   ),
                 ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: fnamecontoller,
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      prefixIconColor: Colors.black,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: 'First Name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter First name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        fname = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: lnamecontroller,
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      prefixIconColor: Colors.black,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: 'Last Name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Last name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        lname = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: mobilenocontroller,
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.mobile_screen_share_outlined),
                      prefixIconColor: Colors.black,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: 'Mobile No',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Mobile No';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        mono = value!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailaddcontoller,
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.email),
                      prefixIconColor: Colors.black,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: 'Email Address',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Email Address';
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        email = value!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    obscureText: passToogle,
                    controller: passwdcontroller,
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      prefixIconColor: Colors.black,
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            passToogle = !passToogle;
                          });
                        },
                        child: Icon(
                          passToogle ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: 'Password',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Password';
                      } else if (value.length < 6) {
                        return 'Minimum length is 6';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        password = value!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      if (_formkey.currentState!.validate()) {
                        signup(email, password, fname, lname, mono);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => login()));
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black87),
                      height: 50,
                      child: const Center(
                        child: Text("Sign Up",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      const Text(
                        'Already have an Account ?',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  login()));
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
