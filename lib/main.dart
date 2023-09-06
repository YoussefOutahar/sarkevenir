import 'package:firebase_core/firebase_core.dart';
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
  await Firebase.initializeApp();

  await Prefs.init();
  // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  // OneSignal.shared.setAppId("a7fe9cdf-3f4b-42a9-ad85-94f3d33ebcbc");
  // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //   print("Accepted permission: $accepted");
  // });
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
