import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget{
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home>{

  Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: WebView(
          initialUrl: 'https://dodimus.com/',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}