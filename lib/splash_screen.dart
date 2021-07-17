import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future fetchData() async {
    Timer(const Duration(milliseconds: 1000), () async {
      http.Response response;
      response = await http.get(Uri.parse(
          "https://api.thingspeak.com/channels/1386933/fields/1.json?api_key=PHFWRP531RNESYBW&results=2"));
      if (response.statusCode == 200) {
        String getData = response.body;
        var grams = jsonDecode(getData);
        var lastId = grams['channel']['last_entry_id'];
        print(lastId);
        for (int i = 0; i < grams['feeds'].length; i++) {
          if (grams['feeds'][i]['entry_id'] == lastId) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => MyApp(grams['feeds'][i]['field1'])));
          }
        }
        print(grams['feeds'][0]['field1']);
      } else {
        print(response.statusCode);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('images/icon.png'),
              height: wp * 0.40,
            ),
            SizedBox(height: 30),
            Container(
                child: Text(
              'Grocery Tracker',
              style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  color: Colors.white),
            ))
          ],
        ),
      ),
    );
  }
}
