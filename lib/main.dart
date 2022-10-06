// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:ui';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'package:http/http.dart' as http;

Future<List<UserDetails>> fetchUserDetails(http.Client client) async {
  final response = await client
      .get(Uri.parse('https://atmygml.github.io/data/jsonplaceholder.json'));

  // Use the compute function to run parseUserDetails in a separate isolate.
  return compute(parseUserDetails, response.body);
}

// A function that converts a response body into a List<UserDetails>.
List<UserDetails> parseUserDetails(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<UserDetails>((json) => UserDetails.fromJson(json)).toList();
}

class UserDetails {
  final String date;
  final String id;
  final String firstName;
  final String lastName;
  final String item;
  final String price;

  const UserDetails({
    required this.date,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.item,
    required this.price,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      date: json['Date'] as String,
      id: json['ID'] as String,
      firstName: json['First Name'] as String,
      lastName: json['Last Name'] as String,
      item: json['Item'] as String,
      price: json['Price'] as String,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Flutter Http Json Demo App v0.1.0");
    setWindowMinSize(const Size(400, 690));
    setWindowMaxSize(const Size(400, 690));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const appTitle = "Flutter Http Json Demo";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      title: 'Flutter Http Json Demo',
      home: const MyHomePage(
        title: appTitle,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: SafeArea(
        child: FutureBuilder<List<UserDetails>>(
          future: fetchUserDetails(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // print(snapshot);
              return Center(
                  child: Text(
                'An error has occurred!',
              )
                  // child: Text('${snapshot.error}'),
                  );
            } else if (snapshot.hasData) {
              return UserDetailsList(userDetails: snapshot.data!);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class UserDetailsList extends StatelessWidget {
  const UserDetailsList({super.key, required this.userDetails});

  final List<UserDetails> userDetails;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: userDetails.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name : ${userDetails[index].firstName} ${userDetails[index].lastName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'UserID : ${userDetails[index].id}',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Item Bought : ${userDetails[index].item}',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Date : ${userDetails[index].date}',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Price : \$ ${userDetails[index].price}',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // ... etc.
      };
}
