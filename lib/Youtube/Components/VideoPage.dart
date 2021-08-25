import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sarkevenir/Youtube/Utils/Downloader.dart';
import 'package:sarkevenir/Youtube/Utils/Player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_youtube_downloader/flutter_youtube_downloader.dart';

class VideoPage extends StatefulWidget {
  final String title;
  final String description;
  final String imgPath;
  final String audioPath;
  const VideoPage(
      {Key key, this.imgPath, this.title, this.description, this.audioPath})
      : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with SingleTickerProviderStateMixin {
  Downloader download = Downloader();
  PlayerYT player = PlayerYT();

  AnimationController _animationController;
  YoutubeExplode yt;
  Video vid;

  String _extractedLink = "";

  bool _isplaying = false;

  Future<void> extractYoutubeLink() async {
    String link;
    try {
      link = await FlutterYoutubeDownloader.extractYoutubeLink(
          widget.audioPath, 18);
    } on PlatformException {
      link = 'Failed to Extract YouTube Video Link.';
    }
    //if (!mounted) return;
    setState(() {
      _extractedLink = link;
    });
  }

  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    //player.stopPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Hero(
                  tag: widget.audioPath,
                  child: Image(image: NetworkImage(widget.imgPath)),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    widget.title,
                    softWrap: true,
                    textScaleFactor:
                        MediaQuery.of(context).textScaleFactor * 1.5,
                    textAlign: TextAlign.center,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.description),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  IconButton(
                      onPressed: () async {
                        await extractYoutubeLink();
                        download.startDownload(
                            link: _extractedLink,
                            title: widget.title,
                            context: context);
                      },
                      icon: Icon(Icons.download)),
                  IconButton(
                      onPressed: () async {
                        if (_extractedLink == "") {
                          await extractYoutubeLink();
                          player.init(_extractedLink);
                          if (_isplaying) {
                            _animationController.reverse();
                            player.pause();
                          } else {
                            _animationController.forward();
                            player.play();
                          }
                          _isplaying = (_isplaying) ? false : true;
                        } else {
                          if (_isplaying) {
                            _animationController.reverse();
                            player.pause();
                          } else {
                            _animationController.forward();
                            player.play();
                          }
                          _isplaying = (_isplaying) ? false : true;
                        }
                      },
                      icon: AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          progress: _animationController)),
                  ProgressBar(
                      progress: Duration(milliseconds: 1000),
                      total: Duration(milliseconds: 5000)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
