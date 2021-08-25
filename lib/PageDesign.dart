import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageDesign extends StatefulWidget {
  const PageDesign({Key key, this.drawer, this.body}) : super(key: key);
  final Widget drawer;
  final Widget body;
  @override
  _PageDesignState createState() => _PageDesignState();
}

class _PageDesignState extends State<PageDesign>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool shouldDrag = false;
  bool isUIHidden = false;
  _open() {
    isUIHidden = true;
    animationController?.forward();
  }

  _close() {
    isUIHidden = false;
    animationController?.reverse();
  }

  _doAnimation() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    animationController.isCompleted ? _close() : _open();
  }

  @override
  void initState() {
    animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: SafeArea(
        child: AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget child) {
            return Row(
              children: [
                IconButton(
                  iconSize: 28,
                  icon: Icon(Icons.menu_rounded),
                  onPressed: _doAnimation,
                ),
                Opacity(
                  opacity: 1 - animationController.value,
                  child: Text(
                    "Sarki Evreni",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          double slide = _deviceSize.width * animationController.value * 1.354;
          double scale = 1 - (animationController.value * 0.5);
          return Stack(
            children: [
              Opacity(
                opacity: animationController.value,
                child: widget.drawer,
              ),
              Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..scale(scale)
                  ..translate(slide),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: animationController.value,
                        child: Center(
                          child: GestureDetector(
                            onTap: _doAnimation,
                            child: Container(
                              child: Icon(
                                Icons.graphic_eq_rounded,
                                size: 150,
                              ),
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 1 - animationController.value,
                        child: IgnorePointer(
                          ignoring: isUIHidden,
                          child: widget.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
