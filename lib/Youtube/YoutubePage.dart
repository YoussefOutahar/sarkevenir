import 'package:flutter/material.dart';
import 'package:outline_search_bar/outline_search_bar.dart';

import '../Data/TurkeyData.dart';
import 'Components/VideoPage.dart';
import 'Components/Vids.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({Key key, @required this.isTurkey}) : super(key: key);
  final bool isTurkey;

  @override
  _YoutubePageState createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  Future<void> _searchQuery;
  TurkeyData _tData = TurkeyData();
  String _currentSearch = "Turkey";
  ScrollController _controller;

  @override
  void initState() {
    _searchQuery = _tData.searchQuery("Turkey");
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.offset >= _controller.position.maxScrollExtent &&
          !_controller.position.outOfRange) {
        print("test");
        _tData.searchQuery(_currentSearch);
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 16, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
            child: OutlineSearchBar(
              borderRadius: BorderRadius.circular(100),
              searchButtonPosition: SearchButtonPosition.leading,
              autoCorrect: true,
              enableSuggestions: true,
              hintText: "Search",
              onSearchButtonPressed: (search) {
                _currentSearch = search;
                _searchQuery = _tData.searchQuery(search);
                setState(() {});
              },
              onClearButtonPressed: (search) {
                _currentSearch = "";
                setState(() {});
              },
            ),
          ),
          FutureBuilder(
            future: _searchQuery,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Expanded(
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
                              title: _tData.metadata[indx]["title"],
                              description: _tData.metadata[indx]["description"],
                              imgPath: _tData.metadata[indx]["imgPath"],
                              audioPath: _tData.metadata[indx]["audioPath"],
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
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
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      Text("Loading Videos")
                    ],
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
