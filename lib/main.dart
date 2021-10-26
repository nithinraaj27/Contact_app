import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_list/add.dart';
import 'package:contact_list/add_contact.dart';
import 'package:contact_list/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<add_details>.value(value: (add_details())),
    ],
    child: MaterialApp(
      home: MyApp(),
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _intialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
            future: _intialization,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text("Error: ${snapshot.error}"),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                return StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, Streamsnapshot) {
                      if (Streamsnapshot.hasError) {
                        return Scaffold(
                          body: Center(
                            child: Text("Error: ${Streamsnapshot.hasError}"),
                          ),
                        );
                      }

                      if (Streamsnapshot.connectionState ==
                          ConnectionState.active) {
                        return Home();
                      }

                      return SafeArea(
                        child: Scaffold(
                          body: Center(
                            child: Text(
                              "Checking Authentication",
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        ),
                      );
                    });
              }
              return Scaffold(
                body: Center(
                  child: Text("Intialising App....."),
                ),
              );
            }),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double h = height / 100;

    double width = MediaQuery.of(context).size.width;
    double w = width / 100;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            " My Contacts",
            style: TextStyle(color: Colors.black, fontSize: h * 3),
          ),
          backgroundColor: Colors.white,
          toolbarHeight: h * 7,
        ),
        floatingActionButton: new FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => add_contacts()));
          },),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: h * 80,
                child: FutureBuilder<QuerySnapshot>(
                    future:
                        FirebaseFirestore.instance.collection('Contacts').get(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(
                            child: Text("error: ${snapshot.error}"),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        int i = 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ListView(
                            children:
                                snapshot.data!.docs.map<Widget>((document) {
                              i++;
                              return get_data(
                                color: i % 2 != 0
                                    ? Colors.blue.shade400
                                    : Colors.red,
                                bg: i % 2 == 0
                                    ? Colors.blue.shade400
                                    : Colors.red,
                                name: document['name'],
                                home: document['home'],
                                cell: document['cell'],
                                address: document['address'],
                                city: document['city'],
                                state: document['state'],
                                zip: document['zip'],
                              );
                            }).toList(),
                          ),
                        );
                      }

                      return Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
