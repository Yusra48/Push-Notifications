import 'package:flutter/material.dart';
import 'package:flutter_application_1/Views/Home/Map_Page.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Maps.png', width: 150, height: 150),
            SizedBox(height: 24),
            Text(
              'Google Maps',
              style: GoogleFonts.bonaNova(
                  textStyle: TextStyle(
                      fontSize: 35,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
            SizedBox(height: 8),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
