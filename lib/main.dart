import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prefs/prefs.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
import 'PageDesign.dart';
import 'Providers/Themes.dart';
import 'SettingsPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Provider.debugCheckInvalidValueType = null;
  await Prefs.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Themes>(create: (_) => Themes()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    theme.getData();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.themeData,
      home: PageDesign(
        body: HomeW(),
        drawer: SettingsPage(),
      ),
    );
  }
}
