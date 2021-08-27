import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prefs/prefs.dart';
import 'HomePage.dart';
import 'PageDesign.dart';
import 'SettingsPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Prefs.init();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PageDesign(
        body: HomeW(),
        drawer: SettingsPage(),
      ),
    );
  }
}
