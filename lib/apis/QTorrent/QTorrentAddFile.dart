part of 'QTorrent.dart';

extension QTorrentAddFile on QTorrent {
  static const String _boundary =
      '--------------------------012345678901234567890123456789';

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
      'Content-Type': 'multipart/form-data; boundary=$_boundary',
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

    String body = '--$_boundary\r\n'
        'Content-Disposition: form-data; name="urls"\r\n\r\n'
        '$url\r\n'
        '--$_boundary--\r\n';

    response = await _makeRequest(HttpMethod.post, 'torrents/add',
        arguments: headers, body: body);

    return response;
  }
}
