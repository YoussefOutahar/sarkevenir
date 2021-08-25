import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TurkeyData {
  var yt = YoutubeExplode();
  String _currentQuery;
  List metadata = [];
  SearchList result;
  Future<void> searchQuery(String query) async {
    if (_currentQuery == query) {
      result = await result.nextPage();
      if (result.isEmpty) {
      } else {
        result.forEach((e) {
          Map v = {
            "title": e.title,
            "description": e.description,
            "imgPath": e.thumbnails.highResUrl,
            "audioPath": e.url
          };
          metadata.add(v);
        });
      }
    } else {
      _currentQuery = query;
      result = await yt.search.getVideos(query);
      if (metadata.isNotEmpty) {
        metadata = [];
      }
      if (query.isEmpty) {
        metadata = [];
      } else {
        if (result.isEmpty) {
          metadata = [];
        } else {
          result.forEach((e) {
            Map v = {
              "title": e.title,
              "description": e.description,
              "imgPath": e.thumbnails.highResUrl,
              "audioPath": e.url
            };
            metadata.add(v);
          });
        }
      }
    }
  }
}
