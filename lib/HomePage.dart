import 'dart:convert';
import 'package:flutter/material.dart';
import 'Features/Network.dart';
import 'Random/RandomDataPage.dart';

import 'Youtube/YoutubePage.dart';

class HomeW extends StatefulWidget {
  const HomeW({
    Key key,
  }) : super(key: key);

  @override
  _HomeWState createState() => _HomeWState();
}

class _HomeWState extends State<HomeW> {
  Future<String> getCountry() async {
    String locationSTR;
    Network n = new Network("http://ip-api.com/json");
    locationSTR = (await n.getData());
    var locationx = jsonDecode(locationSTR);
    return locationx["countryCode"];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FutureBuilder(
        future: getCountry(),
        builder: (context, snapshot) {
          bool isTurkey = (snapshot.data == "MA") ? true : false;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == "MA") {
              return YoutubePage(isTurkey: isTurkey);
            } else {
              return RandomDataPage(isTurkey: isTurkey);
            }
          } else {
            return Padding(
              padding: const EdgeInsets.all(150.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text("Loading Location")
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
