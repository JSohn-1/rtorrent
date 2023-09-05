import 'dart:convert';

import 'package:rtorrent/apis/TorrentServer.dart';

import 'Torrent.dart';
import '../Status.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

enum HttpMethod {
  post,
  get,
}

class QTorrent {
  late final String _url;
  late final String _username;
  late final String _password;
  String cookie = "";

  QTorrent(String url, this._username, this._password) {
    _url = '$url/api/v2/';
  }

  Future<Status> ping() async {
    Response response;

    Map<String, String> headers = {
      'username': _username,
      'password': _password,
    };

    // Get the auth cookie
    response = await _makeRequest(HttpMethod.post, 'auth/login', headers);

    if (response.statusCode == 200) {
      cookie = response.headers['set-cookie']!;
    }

    return Status(response.statusCode, response.body, API.transmission, "");
  }

  Future<List<Torrents>> getTorrents() async {
    Response response;

    Map<String, String> headers = {
      'Cookie': cookie,
    };

    response = await _makeRequest(HttpMethod.get, 'torrents/info', headers);

    List<Torrents> torrents = [];

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);

      for (dynamic torrent in json) {
        TorrentStatus status = TorrentStatus.stopped;
        if (torrent['state'] == 'downloading') {
          status = TorrentStatus.downloading;
        } else if (torrent['state'] == 'queuedDL') {
          status = TorrentStatus.queuedToDownload;
        } else if (torrent['state'] == 'stalledUP' ||
            torrent['state'] == 'stalledDL') {
          status = TorrentStatus.paused;
        } else if (torrent['state'] == '')
          torrents.add(Torrent(
            torrent['name'],
          ));
      }
    }

    return torrents;
  }

  Future<Response> _makeRequest(HttpMethod httpMethod, String method,
      [Map<String, String> arguments = const {}]) async {
    Response? response;

    if (httpMethod == HttpMethod.post) {
      await http
          .post(Uri.parse('$_url$method'), body: arguments)
          .then((_) => response = _);
    } else if (httpMethod == HttpMethod.get) {
      await http.get(Uri.parse('$_url$method')).then((_) => response = _);
    }

    return response!;
  }
}
