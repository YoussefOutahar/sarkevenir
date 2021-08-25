import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TurkeyData {
  var yt = YoutubeExplode();
  String _currentQuery;
  List metadata = [];
  SearchList result;
  Future<void> searchQuery(String query, int tries) async {
    if (_currentQuery == query) {
      result = await result.nextPage();
      result.forEach((e) {
        Map v = {
          "title": e.title,
          "description": e.description,
          "imgPath": e.thumbnails.highResUrl,
          "audioPath": e.url
        };
        metadata.add(v);
      });
    } else {
      _currentQuery = query;
      result = await yt.search.getVideos(query);
      if (metadata.isNotEmpty) {
        metadata = [];
      }
      if (query.isEmpty) {
        metadata = [];
      } else {
        for (var i = 0; i < tries; i++) {
          result.forEach((e) {
            Map v = {
              "title": e.title,
              "description": e.description,
              "imgPath": e.thumbnails.highResUrl,
              "audioPath": e.url
            };
            metadata.add(v);
          });
          result = await result.nextPage();
        }
      }
    }
  }
}
