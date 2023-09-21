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
      cookie = response.headers['set-cookie']!
          .substring(0, response.headers['set-cookie']!.indexOf(';'));
    }

    return Status(response.statusCode, response.body, API.transmission, "");
  }

  Future<List<Torrent>> getTorrents() async {
    Response response;

    Map<String, String> headers = {
      'cookie': cookie,
    };

    response = await _makeRequest(HttpMethod.get, 'torrents/info', headers);

    if (response.statusCode == 403) {
      await ping().then((_) async {
        if (_.code != 200) {
          throw Exception('Failed to authenticate: ${response.body}');
        }
        response = await _makeRequest(HttpMethod.get, 'torrents/info', headers);
        return true;
      });
    }

    List<Torrent> torrents = [];

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      for (dynamic torrent in json) {
        TorrentStatus status = TorrentStatus.inactive;

        switch (torrent['state']) {
          case 'error':
          case 'unknown':
            status = TorrentStatus.error;
            break;

          case 'downloading':
          case 'forcedDL':
          case 'metaDL':
            status = TorrentStatus.downloading;
            break;

          case 'queuedDL':
          case 'queuedUP':
          case 'stalledUP':
          case 'stalledDL':
          case 'pausedUP':
          case 'pausedDL':
            status = TorrentStatus.inactive;
            break;

          case 'forcedUP':
          case 'uploading':
            status = TorrentStatus.seeding;
            break;

          case 'checkingUP':
          case 'checkingDL':
            status = TorrentStatus.verifying;
            break;

          case 'moving':
          case 'allocating':
          case 'checkingResumeData':
            status = TorrentStatus.localchange;
            break;
          default:
            status = TorrentStatus.inactive;
            break;
        }

        torrents.add(Torrent(
            torrent['name'],
            status,
            torrent['state'],
            torrent['downloaded'],
            torrent['dlspeed'],
            torrent['uploaded'],
            torrent['upspeed'],
            torrent['size'],
            torrent['progress'],
            Duration(seconds: torrent['eta']),
            torrent['num_seeds']));
      }
      return torrents;
    }
    throw Exception('Failed to get torrents: ${response.body}');
  }

  Future<Response> addTorrentByURLSingle(
    Uri url, {
    bool paused = false,
  }) async {
    Response response;

    Map<String, String> headers = {
      'cookie': cookie,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/info', headers);

    if (response.statusCode == 403) {
      await ping().then((_) async {
        if (_.code != 200) {
          throw Exception('Failed to authenticate: ${response.body}');
        }
        response = await _makeRequest(HttpMethod.get, 'torrents/info', headers);
        return true;
      });
    }

    return response;
  }

  Future<Response> _makeRequest(HttpMethod httpMethod, String method,
      [Map<String, String> arguments = const {}]) async {
    Response? response;

    arguments['Cookie'] = cookie == "" ? "" : cookie;

    if (httpMethod == HttpMethod.post) {
      await http
          .post(Uri.parse('$_url$method'), body: arguments)
          .then((_) => response = _);
    } else if (httpMethod == HttpMethod.get) {
      await http
          .get(
            Uri.parse('$_url$method'),
            headers: arguments,
          )
          .then((_) => response = _);
    }

    return response!;
  }
}
