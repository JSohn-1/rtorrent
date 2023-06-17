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
  late final Uri _url;
  late final String _username;
  late final String _password;
  String cookie = "";

  QTorrent(this._url, this._username, this._password);

  Future<Status> ping() async {
    Response response;

    Map<String, String> headers = {
      'username': _username,
      'password': _password,
    };

    try {
      response =
          await http.post(_url, headers: headers).then((_) => response = _);
    } catch (e) {
      return Status(0, e.toString(), API.qBittorrent,
          "Could not connect to server. Please check your connection");
    }

    if (response.statusCode == 200) {
      cookie = response.headers['Set-Cookie']!;
    }

    return Status(response.statusCode, response.body, API.transmission, "");
  }

  Future<Response> _makeRequest(HttpMethod httpMethod, String method,
      [Map<String, dynamic> arguments = const {}]) async {
    Response? response;

    // Map<String, String> headers = {};

    if (httpMethod == HttpMethod.post) {
      await http
          .post(_url, body: jsonEncode(arguments))
          .then((_) => response = _);
    } else if (httpMethod == HttpMethod.get) {
      await http.get(_url).then((_) => response = _);
    }

    return response!;
  }
}
