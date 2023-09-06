import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sarkevenir/Providers/Themes.dart';
import 'package:sarkevenir/Youtube/Utils/Downloader.dart';
import 'package:sarkevenir/Youtube/Utils/Player.dart';
import 'package:flutter_youtube_downloader/flutter_youtube_downloader.dart';

class VideoPage extends StatefulWidget {
  final String title;
  final String description;
  final String imgPath;
  final String audioPath;
  final PlayerYT player;
  const VideoPage(
      {Key key,
      this.imgPath,
      this.title,
      this.description,
      this.audioPath,
      this.player})
      : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with SingleTickerProviderStateMixin {
  Downloader download = Downloader();

  AnimationController _animationController;
  Future<String> _extractedLink;

  bool _isplaying = false;
  int firstTry = 0;

  Future<String> extractYoutubeLink() async {
    String link;
    try {
      link = await FlutterYoutubeDownloader.extractYoutubeLink(
          widget.audioPath, 18);
    } on PlatformException {
      link = 'Failed to Extract YouTube Video Link.';
    }
    //if (!mounted) return;
    return link;
  }

  Stream<dynamic> startProgress;

  @override
  void initState() {
    widget.player.init();
    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _extractedLink = Future(() async {
      String link;
      link = await extractYoutubeLink();
      return link;
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _extractedLink,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Hero(
                          tag: widget.audioPath,
                          child: Image(
                            image: NetworkImage(widget.imgPath),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            0,
                            MediaQuery.of(context).size.height / 32,
                            0,
                            MediaQuery.of(context).size.height / 32),
                        width: MediaQuery.of(context).size.width * (1 - 1 / 8),
                        child: StreamBuilder(
                          stream: startProgress,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              return ProgressBar(
                                progressBarColor: theme.color,
                                thumbColor: theme.color,
                                bufferedBarColor: theme.color.withOpacity(0.3),
                                baseBarColor: theme.color.withOpacity(0.1),
                                thumbGlowColor: theme.color.withOpacity(0.3),
                                onSeek: (Duration seek) {
                                  widget.player.seek(seek);
                                },
                                buffered:
                                    (widget.player.getBufferPosition() == null)
                                        ? Duration.zero
                                        : widget.player.getBufferPosition(),
                                progress: (widget.player.getPosition() == null)
                                    ? Duration.zero
                                    : snapshot.data,
                                total: (widget.player.getTotalTime() == null)
                                    ? Duration.zero
                                    : widget.player.getTotalTime(),
                              );
                            } else {
                              return ProgressBar(
                                progressBarColor: theme.color,
                                thumbColor: theme.color,
                                bufferedBarColor: theme.color.withOpacity(0.3),
                                baseBarColor: theme.color.withOpacity(0.1),
                                thumbGlowColor: theme.color.withOpacity(0.3),
                                onSeek: (Duration seek) {
                                  widget.player.seek(seek);
                                },
                                buffered: Duration.zero,
                                progress: Duration.zero,
                                total: Duration.zero,
                              );
                            }
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Material(
                              elevation: 10,
                              color: theme.color,
                              borderRadius: BorderRadius.circular(100),
                              child: IconButton(
                                  color: Colors.white,
                                  onPressed: () {
                                    widget.player.rewind();
                                  },
                                  icon: Icon(
                                    Icons.fast_rewind_rounded,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width / 32,
                                0,
                                MediaQuery.of(context).size.width / 32,
                                0),
                            child: ClipOval(
                              child: Material(
                                elevation: 10,
                                color: theme.color,
                                borderRadius: BorderRadius.circular(100),
                                child: IconButton(
                                  padding: EdgeInsets.all(15),
                                  iconSize: 30,
                                  onPressed: () async {
                                    try {
                                      if (firstTry == 0) {
                                        _animationController.forward();
                                        await widget.player.setAudioLink(
                                            snapshot.data,
                                            widget.imgPath,
                                            widget.title);
                                        widget.player.play();
                                        _isplaying =
                                            (_isplaying) ? false : true;
                                        firstTry = firstTry + 1;
                                        startProgress =
                                            widget.player.getPosition();
                                        setState(() {});
                                      } else {
                                        if (_isplaying) {
                                          _animationController.reverse();
                                          widget.player.pause();
                                        } else {
                                          _animationController.forward();
                                          widget.player.play();
                                        }
                                        _isplaying =
                                            (_isplaying) ? false : true;
                                      }
                                    } catch (e) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: AnimatedIcon(
                                      color: Colors.white,
                                      icon: AnimatedIcons.play_pause,
                                      progress: _animationController),
                                ),
                              ),
                            ),
                          ),
                          ClipOval(
                            child: Material(
                              elevation: 10,
                              color: theme.color,
                              borderRadius: BorderRadius.circular(100),
                              child: IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  widget.player.forward();
                                },
                                icon: Icon(Icons.fast_forward_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: Container()),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          widget.description,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: MediaQuery.of(context).size.height / 3.3,
                    child: Padding(
                      padding: EdgeInsets.all(18.5),
                      child: ClipRRect(
                        child: Material(
                          color: theme.color,
                          borderRadius: BorderRadius.circular(20),
                          child: IconButton(
                            color: Colors.white,
                            padding: EdgeInsets.all(15),
                            iconSize: 30,
                            icon: Icon(Icons.download),
                            onPressed: () async {
                              download.startDownload(
                                link: snapshot.data,
                                title: widget.title,
                                context: context,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(1),
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_rounded),
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Text(
                          widget.title,
                          style: TextStyle(color: Colors.white),
                          softWrap: true,
                          textScaleFactor:
                              MediaQuery.of(context).textScaleFactor * 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Center(
                  child: CircularProgressIndicator(
                color: theme.color,
              ));
            }
          },
        ),
      ),
    );
  }
}
