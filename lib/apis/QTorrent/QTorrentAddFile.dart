part of 'QTorrent.dart';

extension QTorrentAddFile on QTorrent {
  Future<Response> addTorrentByURLSingle(
    String url, {
    bool paused = false,
    String? savePath,
    String? category,
    String? skipCheck,
    String? rootFolder,
    String? rename,
    String? upLimit,
    String? dlLimit,
    String? autoTMM,
    String? sequentialDownload,
    String? firstLastPiecePrio,
  }) async {
    Response response;

    Map<String, String> headers = {
      'urls': url,
      if (paused) 'paused': 'true',
      if (savePath != null) 'savepath': savePath,
      if (category != null) 'category': category,
      if (skipCheck != null) 'skip_checking': skipCheck,
      if (rootFolder != null) 'root_folder': rootFolder,
      if (rename != null) 'rename': rename,
      if (upLimit != null) 'upLimit': upLimit,
      if (dlLimit != null) 'dlLimit': dlLimit,
      if (autoTMM != null) 'autoTMM': autoTMM,
      if (sequentialDownload != null) 'sequentialDownload': sequentialDownload,
      if (firstLastPiecePrio != null) 'firstLastPiecePrio': firstLastPiecePrio,
    };

    response =
        await _makeRequest(HttpMethod.post, 'torrents/add', arguments: headers);

    return response;
  }
}
