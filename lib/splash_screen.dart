import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:live_caption_generator/caption_generate.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(
        seconds: 5,
      ),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: Image.asset(
              "assets/background.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Color.fromRGBO(
              255,
              255,
              255,
              0.4,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  child: FlareActor(
                    'assets/animate.flr',
                    animation: "open",
                  ),
                ),
                Container(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.teal,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 20,
                  ),
                ),
                Text(
                  "Caption Generator",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}