import 'package:admin_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyD1oWEc2G4-VvqMyETk1DOnkoJe8l64DEI",
          authDomain: "flutter-uber-clone-f49e2.firebaseapp.com",
          databaseURL: "https://flutter-uber-clone-f49e2-default-rtdb.firebaseio.com",
          projectId: "flutter-uber-clone-f49e2",
          storageBucket: "flutter-uber-clone-f49e2.appspot.com",
          messagingSenderId: "688874778360",
          appId: "1:688874778360:web:a5043b91d0412a6556550d",
          measurementId: "G-T43VDFD6BP"
      )
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SideNavigationDrawer(),
    );
  }
}


