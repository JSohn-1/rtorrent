import 'dart:convert';

import 'package:rtorrent/apis/TorrentServer.dart';

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
    print(response.headers);

    if (response.statusCode == 200) {
      cookie = response.headers['Set-Cookie']!;
    }

    return Status(response.statusCode, response.body, API.transmission, "");
  }

  Future<Response> _makeRequest(HttpMethod httpMethod, String method,
      [Map<String, String> arguments = const {}]) async {
    Response? response;

    if (httpMethod == HttpMethod.post) {
      await http
          .post(Uri.parse('$_url$method'), headers: arguments)
          .then((_) => response = _);
    } else if (httpMethod == HttpMethod.get) {
      await http.get(Uri.parse('$_url$method')).then((_) => response = _);
    }

    return response!;
  }
}
