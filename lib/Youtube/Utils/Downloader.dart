import 'dart:io';
import 'package:flowder/flowder.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prefs/prefs.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class Downloader {
  DownloaderUtils options;
  DownloaderCore core;
  String path;

  Future<void> initPlatformState() async {
    _setPath();
    //if (!mounted) return;
  }

  void _setPath() async {
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
    pd.show(max: 100, msg: 'File Downloading...');
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
  }
}
