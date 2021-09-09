import 'package:provider/provider.dart';

import '/Youtube/Utils/Player.dart';
import 'package:flutter/material.dart';

import 'Providers/Themes.dart';

class Vids extends StatefulWidget {
  final String title;
  final String description;
  final String imgPath;
  final String audioPath;
  final bool isturkey;
  const Vids({
    Key key,
    this.title,
    this.description,
    this.imgPath,
    this.audioPath,
    this.isturkey,
  }) : super(key: key);

  @override
  _VidsState createState() => _VidsState();
}

class _VidsState extends State<Vids> with SingleTickerProviderStateMixin {
  final assetsAudioPlayer = PlayerYT();
  AnimationController animationController;
  bool _isplaying = false;

  void _playGlobalData() {
    assetsAudioPlayer.initAsset(widget.audioPath);
    if (_isplaying) {
      animationController.reverse();
      assetsAudioPlayer.pause();
    } else {
      animationController.forward();
      assetsAudioPlayer.play();
    }
    _isplaying = (_isplaying) ? false : true;
  }

  @override
  void initState() {
    animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    return Stack(
      children: [
        Positioned(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.color,
                    width: 2.5,
                  ),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  height: MediaQuery.of(context).size.height / 8,
                  child: Hero(
                    tag: widget.audioPath,
                    child: CircleAvatar(
                      foregroundImage: NetworkImage(
                        widget.imgPath,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          child: Container(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  widget.title,
                  softWrap: true,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaleFactor * 17),
                ),
              ),
              margin: EdgeInsets.all(20)),
          left: MediaQuery.of(context).size.width / 4,
          right: MediaQuery.of(context).size.width / 8,
          top: 0,
          bottom: 0,
        ),
        if (!widget.isturkey)
          // Positioned(
          //   child: Container(
          //     child: Text(widget.description),
          //     margin: EdgeInsets.all(20),
          //   ),
          //   left: MediaQuery.of(context).size.width / 4,
          //   top: 35,
          // ),
          if (!widget.isturkey)
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height / 20,
              bottom: 0,
              child: Container(
                margin: EdgeInsets.all(20),
                child: InkWell(
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    size: 40,
                    progress: animationController,
                  ),
                  onTap: () {
                    _playGlobalData();
                  },
                ),
              ),
            ),
      ],
    );
  }
}
