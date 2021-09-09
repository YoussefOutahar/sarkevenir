import 'dart:io';
import 'package:flowder/flowder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prefs/prefs.dart';
import 'package:provider/provider.dart';
import 'package:sarkevenir/Providers/Themes.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class Downloader {
  DownloaderUtils options;
  DownloaderCore core;
  String path;

  Future<void> initPlatformState() async {
    var p = Prefs.getString("path");
    if (p.isNotEmpty) {
      path = p;
    } else {
      path = "/storage/emulated/0/Music";
    }
  }

  void startDownload({String link, String title, BuildContext context}) async {
    ProgressDialog pd = ProgressDialog(context: context);
    var status = Permission.storage;
    await status.request();
    await initPlatformState();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Themes theme = Provider.of<Themes>(context);
        return AlertDialog(
          actions: [
            TextButton(
              child: Text("Download as Music"),
              onPressed: () async {
                pd.show(
                    max: 100,
                    msg: 'File Downloading...',
                    progressValueColor: theme.color,
                    progressBgColor: (theme.themeData ==
                            ThemeData(brightness: Brightness.light))
                        ? Colors.grey[300]
                        : Colors.grey[800],
                    backgroundColor: (theme.themeData ==
                            ThemeData(brightness: Brightness.light))
                        ? Colors.white
                        : Theme.of(context).scaffoldBackgroundColor);
                options = DownloaderUtils(
                  progressCallback: (current, total) {
                    final progress = (current / total) * 100;
                    pd.update(value: progress.toInt());
                  },
                  file: File('$path/' + title + '.mp3'),
                  progress: ProgressImplementation(),
                  onDone: () => pd.close(),
                  deleteOnCancel: false,
                );
                core = await Flowder.download(link, options);
              },
            ),
            TextButton(
              child: Text("Download as Video"),
              onPressed: () async {
                pd.show(
                    max: 100,
                    msg: 'File Downloading...',
                    progressValueColor: theme.color,
                    progressBgColor: (theme.themeData ==
                            ThemeData(brightness: Brightness.light))
                        ? Colors.grey[300]
                        : Colors.grey[800],
                    backgroundColor: (theme.themeData ==
                            ThemeData(brightness: Brightness.light))
                        ? Colors.white
                        : Theme.of(context).scaffoldBackgroundColor);
                options = DownloaderUtils(
                  progressCallback: (current, total) {
                    final progress = (current / total) * 100;
                    pd.update(value: progress.toInt());
                  },
                  file: File('$path/' + title + '.mp4'),
                  progress: ProgressImplementation(),
                  onDone: () => pd.close(),
                  deleteOnCancel: true,
                );
                core = await Flowder.download(link, options);
              },
            )
          ],
        );
      },
    );
  }
}
