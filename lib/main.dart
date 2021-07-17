import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'splash_screen.dart';

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
  ));
}

class MyApp extends StatefulWidget {
  final currentWt;
  MyApp(this.currentWt);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String prevWeight = '';
  String difference = '';
  String currentWeight = '';
  String calories = '',
      carbo = '',
      fat = '',
      potassium = '',
      sodium = '',
      protein = '';
  bool added = false;
  Future fetchData() async {
    http.Response response;
    response = await http.get(Uri.parse(
        "https://api.thingspeak.com/channels/1386933/fields/1.json?api_key=PHFWRP531RNESYBW&results=2"));
    if (response.statusCode == 200) {
      String getData = response.body;
      var grams = jsonDecode(getData);
      var lastId = grams['channel']['last_entry_id'];
      for (int i = 0; i < grams['feeds'].length; i++) {
        if (grams['feeds'][i]['entry_id'] == lastId) {
          setState(() {
            prevWeight = grams['feeds'][i - 1]['field1'];
            currentWeight = grams['feeds'][i]['field1'];
          });
          break;
        }
      }
      setState(() {
        var diff = (double.parse(prevWeight) - double.parse(currentWeight))
            .roundToDouble();
        if (diff < 0) {
          setState(() {
            added = true;
            diff = -1 * diff;
            calories = '';
            difference = diff.toString();
          });
        } else {
          setState(() {
            var cal = diff * 1.3;
            calories = cal.toString();
            var carb = (diff * 0.28).roundToDouble();
            carbo = carb.toString();
            var f = (0.003 * diff).roundToDouble();
            fat = f.toString();
            var p = (0.35 * diff).roundToDouble();
            potassium = p.toString();
            var s = (0.01 * diff).roundToDouble();
            sodium = s.toString();
            var pr = (0.027 * diff).roundToDouble();
            protein = pr.toString();
            difference = diff.toString();
            added = false;
          });
        }
      });
    } else {
      print(response.statusCode);
    }
    if (double.parse(currentWeight) < 300) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Text(
                'Your jar is getting empty',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                  'Please follow this link\nhttps://www.bigbasket.com/',
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: "https://www.bigbasket.com/"));
                    Navigator.pop(context);
                  },
                  child:
                      Text('Copy link', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          });
    }
  }

  void getData() {
    setState(() {
      currentWeight = widget.currentWt;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(
          "Grocery Tracker",
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              width: wp * 0.95,
              height: difference != '' ? wp * 0.65 : wp * 0.45,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  border: Border.all(
                    color: Colors.red[500],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Rice',
                        style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 7),
                    prevWeight != ''
                        ? Text(
                            "Previous Weight = $prevWeight",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          )
                        : Container(),
                    SizedBox(height: 10),
                    currentWeight != ''
                        ? Text(
                            "Current Weight = $currentWeight",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          )
                        : Container(),
                    SizedBox(height: 7),
                    difference != ''
                        ? Divider(color: Colors.black)
                        : Container(),
                    difference != ''
                        ? Text(
                            added
                                ? "Weight Added = $difference"
                                : "Calories Consumed = $calories",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          )
                        : Container(),
                    SizedBox(height: 7),
                    if (!added && difference != '')
                      Column(
                        children: [
                          Text(
                            "Total Carbohydrates = $carbo g",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                          SizedBox(height: 7),
                          Text(
                            "Total Fat = $fat g",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                          SizedBox(height: 7),
                          Text(
                            "Total Potassium = $potassium mg",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                          SizedBox(height: 7),
                          Text(
                            "Total Sodium = $sodium mg",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                          SizedBox(height: 7),
                          Text(
                            "Total Protein = $protein mg",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ],
                      )
                    else
                      Container(),
                  ],
                ),
              ),
            ),
            Image(
              image: AssetImage('images/icon.png'),
              height: wp * 0.50,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ButtonTheme(
                minWidth: wp * 0.88,
                height: 55.0,
                child: MaterialButton(
                  padding: const EdgeInsets.all(8.0),
                  textColor: Colors.white,
                  color: Colors.redAccent,
                  onPressed: () {
                    fetchData();
                  },
                  child: Text(
                    "Refresh",
                    style:
                        TextStyle(fontSize: 16, fontFamily: 'BrandonTextReg'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
