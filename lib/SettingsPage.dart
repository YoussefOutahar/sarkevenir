import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 3,
    remindDays: 7,
    remindLaunches: 10,
    googlePlayIdentifier: 'com.outahar.qequalizer',
  );
  String _url =
      "https://www.paypal.com/paypalme/my/settings?flow=cmV0dXJuVXJsPS9teWFjY291bnQvdHJhbnNmZXIvaG9tZXBhZ2UvcmVxdWVzdCZjYW5jZWxVcmw9L215YWNjb3VudC90cmFuc2Zlci9ob21lcGFnZS9yZXF1ZXN0";
  void _launchURL() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
  @override
  void initState() {
    super.initState();
    rateMyApp.init().then(
      (_) {
        if (rateMyApp.shouldOpenDialog) {
          rateMyApp.showRateDialog(
            context,
            title: 'Rate this app', // The dialog title.
            message:
                'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.', // The dialog message.
            rateButton: 'RATE', // The dialog "rate" button text.
            noButton: 'NO THANKS', // The dialog "no" button text.
            // The dialog "later" button text.
            listener: (button) {
              // The button click listener (useful if you want to cancel the click event).
              switch (button) {
                case RateMyAppDialogButton.rate:
                  print('Clicked on "Rate".');
                  break;
                case RateMyAppDialogButton.later:
                  print('Clicked on "Later".');
                  break;
                case RateMyAppDialogButton.no:
                  print('Clicked on "No".');
                  break;
              }
              return true; // Return false if you want to cancel the click event.
            },
            ignoreNativeDialog: Platform
                .isAndroid, // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
            dialogStyle: const DialogStyle(), // Custom dialog styles.
            onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
                .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
            // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
            // actionsBuilder: (context) => [], // This one allows you to use your own buttons.
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var _screenData = MediaQuery.of(context);
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: _screenData.size.height / 3.8,
          ),
          SizedBox(height: _screenData.size.height / 64),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text("Change Download Path"),
            onTap: () async {
              await Permission.storage.request();
              await Permission.manageExternalStorage.request();
              String path = await FilesystemPicker.open(
                title: 'Save to folder',
                context: context,
                rootDirectory: Directory("/storage/emulated/0").absolute,
                fsType: FilesystemType.folder,
                pickText: 'Save file to this folder',
                //folderIconColor: Colors.teal,
              );
              if (!(path == null || path.isEmpty)) {
                Prefs.setString("path", path);
              }
            },
          ),
          SizedBox(height: _screenData.size.height / 64),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text("Donate"),
            onTap: () {
              _launchURL();
            },
          ),
          SizedBox(height: _screenData.size.height / 64),
          ListTile(
            title: Text("About"),
            leading: Icon(Icons.perm_device_information_sharp),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Sarki Evreni",
                applicationVersion: "v0.5",
                applicationLegalese:
                    "Sarki Something Something Something Something",
              );
            },
          ),
        ],
      ),
    );
  }
}
