import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarkevenir/Data/GlobalData.dart';
import 'package:sarkevenir/Providers/Themes.dart';
import 'package:sarkevenir/Vids.dart';

class RandomDataPage extends StatefulWidget {
  const RandomDataPage({Key key, @required this.isTurkey}) : super(key: key);
  final bool isTurkey;
  @override
  _RandomDataPageState createState() => _RandomDataPageState();
}

class _RandomDataPageState extends State<RandomDataPage> {
  GlobalData _gData = GlobalData();
  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    theme.getData();
    return Container(
      padding:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 16, 0, 0),
      child: ListView.builder(
        addAutomaticKeepAlives: true,
        itemCount: _gData.globalData.length,
        itemBuilder: (context, indx) {
          return Container(
            decoration: BoxDecoration(
              color:
                  (theme.themeData == ThemeData(brightness: Brightness.light))
                      ? Colors.grey[300]
                      : Colors.grey[800],
              borderRadius: BorderRadius.circular(35),
            ),
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Vids(
              isturkey: widget.isTurkey,
              title: _gData.globalData[indx]["title"],
              description: _gData.globalData[indx]["description"],
              imgPath: _gData.globalData[indx]["imgPath"],
              audioPath: _gData.globalData[indx]["audioPath"],
            ),
          );
        },
      ),
    );
  }
}
