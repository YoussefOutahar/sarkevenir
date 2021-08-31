import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sarkevenir/Providers/Themes.dart';
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

  Future<String> _extractedLink;

  bool _isplaying = false;

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

  @override
  void initState() {
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
    player.stopPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                SizedBox(height: 60),
                FutureBuilder(
                  future: _extractedLink,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        width: MediaQuery.of(context).size.width * (1 - 1 / 16),
                        child: FutureBuilder(
                          future: player.init(snapshot.data),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return StreamBuilder(
                                stream: player.getPosition(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.active) {
                                    return ProgressBar(
                                      progressBarColor: theme.color,
                                      thumbColor: theme.color,
                                      bufferedBarColor:
                                          theme.color.withOpacity(0.3),
                                      baseBarColor:
                                          theme.color.withOpacity(0.1),
                                      thumbGlowColor:
                                          theme.color.withOpacity(0.3),
                                      onSeek: (Duration seek) {
                                        player.seek(seek);
                                      },
                                      buffered:
                                          (player.getBufferPosition() == null)
                                              ? Duration.zero
                                              : player.getBufferPosition(),
                                      progress: (player.getPosition() == null)
                                          ? Duration.zero
                                          : snapshot.data,
                                      total: (player.getTotalTime() == null)
                                          ? Duration.zero
                                          : player.getTotalTime(),
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      );
                    } else {
                      return CircularProgressIndicator(
                        color: theme.color,
                      );
                    }
                  },
                ),
                FutureBuilder(
                  future: _extractedLink,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return FutureBuilder(
                          future: player.init(snapshot.data),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Row(
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
                                            player.rewind();
                                          },
                                          icon: Icon(
                                            Icons.fast_rewind_rounded,
                                          )),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: ClipOval(
                                      child: Material(
                                        elevation: 10,
                                        color: theme.color,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: IconButton(
                                          padding: EdgeInsets.all(15),
                                          iconSize: 30,
                                          onPressed: () async {
                                            if (snapshot.data == "") {
                                              if (_isplaying) {
                                                _animationController.reverse();
                                                player.pause();
                                              } else {
                                                _animationController.forward();
                                                player.play();
                                              }
                                              _isplaying =
                                                  (_isplaying) ? false : true;
                                            } else {
                                              player.init(snapshot.data);
                                              if (_isplaying) {
                                                _animationController.reverse();
                                                player.pause();
                                              } else {
                                                _animationController.forward();
                                                player.play();
                                              }
                                              _isplaying =
                                                  (_isplaying) ? false : true;
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
                                          player.forward();
                                        },
                                        icon: Icon(Icons.fast_forward_rounded),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator(
                                color: theme.color,
                              );
                            }
                          });
                    } else {
                      return Container();
                    }
                  },
                )
              ],
            ),
            FutureBuilder(
              future: _extractedLink,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Positioned(
                    right: 0,
                    top: MediaQuery.of(context).size.height / 3.2,
                    child: Padding(
                      padding: const EdgeInsets.all(18.5),
                      child: ClipRRect(
                        child: Material(
                          elevation: 10,
                          color: theme.color,
                          borderRadius: BorderRadius.circular(20),
                          child: IconButton(
                            color: Colors.white,
                            padding: EdgeInsets.all(15),
                            iconSize: 30,
                            icon: Icon(Icons.download),
                            onPressed: () async {
                              await extractYoutubeLink();
                              download.startDownload(
                                  link: snapshot.data,
                                  title: widget.title,
                                  context: context);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height / 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
