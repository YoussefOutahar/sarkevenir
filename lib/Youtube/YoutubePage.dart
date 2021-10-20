import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:prefs/prefs.dart';
import 'package:provider/provider.dart';
import 'package:sarkevenir/Providers/Themes.dart';
import 'package:sarkevenir/Youtube/Utils/Player.dart';
import '../Data/TurkeyData.dart';
import 'Components/VideoPage.dart';
import '../Vids.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({Key key, @required this.isTurkey}) : super(key: key);
  final bool isTurkey;

  @override
  _YoutubePageState createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  Future<void> _searchQuery;
  TurkeyData _tData = TurkeyData();
  String _currentSearch;
  TextEditingController _textEditingController;
  ScrollController _controller;
  PlayerYT _player = PlayerYT();

  @override
  void initState() {
    _currentSearch = Prefs.getString("search");
    if (_currentSearch == "") {
      _currentSearch = "Music";
      _searchQuery = _tData.searchQuery(_currentSearch);
    } else {
      _searchQuery = _tData.searchQuery(_currentSearch);
    }
    _controller = ScrollController();
    _textEditingController = TextEditingController();
    _controller.addListener(() {
      if (_controller.offset >= _controller.position.maxScrollExtent &&
          !_controller.position.outOfRange) {
        _tData.searchQuery(_currentSearch);
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Themes theme = Provider.of<Themes>(context);
    theme.getData();
    return Container(
      padding:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 16, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.color,
                  ),
                  suffixIcon: IconButton(
                    splashRadius: MediaQuery.of(context).textScaleFactor / 0.5,
                    onPressed: () {
                      _currentSearch = "";
                      _textEditingController.text = "";
                      setState(() {});
                    },
                    icon: Icon(Icons.clear),
                    color: (theme.themeData ==
                            ThemeData(brightness: Brightness.light))
                        ? Colors.grey[300]
                        : Colors.grey[800],
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: theme.color,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: theme.color,
                    ),
                  ),
                ),
                onSubmitted: (search) {
                  _currentSearch = search;
                  Prefs.setString("search", _currentSearch);
                  _searchQuery = _tData.searchQuery(search);
                  setState(() {});
                },
              ),
              suggestionsCallback: (String pattern) {
                return _tData.suggestions(pattern);
              },
              itemBuilder: (BuildContext context, String itemData) {
                return ListTile(
                  title: Text(itemData),
                );
              },
              onSuggestionSelected: (String suggestion) {
                _currentSearch = suggestion;
                _textEditingController.text = suggestion;
                _searchQuery = _tData.searchQuery(suggestion);
                setState(() {});
              },
            ),
          ),
          FutureBuilder(
            future: _searchQuery,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Expanded(
                  child: GlowingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    color: theme.color,
                    child: ListView.builder(
                      controller: _controller,
                      addAutomaticKeepAlives: true,
                      itemCount: _tData.metadata.length,
                      itemBuilder: (context, indx) {
                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPage(
                                player: _player,
                                title: _tData.metadata[indx]["title"],
                                description: _tData.metadata[indx]
                                    ["description"],
                                imgPath: _tData.metadata[indx]["imgPath"],
                                audioPath: _tData.metadata[indx]["audioPath"],
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: (theme.themeData ==
                                      ThemeData(brightness: Brightness.light))
                                  ? Colors.grey[300]
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(35),
                            ),
                            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Vids(
                              isturkey: widget.isTurkey,
                              title: _tData.metadata[indx]["title"],
                              description: _tData.metadata[indx]["description"],
                              imgPath: _tData.metadata[indx]["imgPath"],
                              audioPath: _tData.metadata[indx]["audioPath"],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(
                    color: theme.color,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
