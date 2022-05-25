import 'package:dodimus/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Splash extends StatefulWidget {
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  int doubleTappedText = 0;

  @override
  void initState() {
    super.initState();
    _splash();
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Container(
              width: MediaQuery.of(context).size.width/2,
              height: MediaQuery.of(context).size.width/2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/logo_transparente.png'),
                    fit: BoxFit.fill),
              ),
          ),
        ),
      ),
    );
  }

  _splash() async {
    await Permission.storage.request();
    await Future.delayed(Duration(seconds: 1), () {});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

}
