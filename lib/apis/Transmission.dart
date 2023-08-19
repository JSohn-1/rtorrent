// import 'dart:html';
import '../Status.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'TorrentServer.dart';
import 'Torrent.dart';

class TransmissionRPC {
  // Make a class that will act as a wrapper for the transmission RPC
  late final Uri _url;
  late final String _username;
  late final String _password;
  // Make a variable that will hold the path to the transmission RPC, but the path is optional
  String? _sessionId;

  TransmissionRPC(url, this._username, this._password, {String path = ""}) {
    // If path is empty, append /transmission/rpc to the url. If it is not append path to the end of the url
    if (path == "") {
      _url = Uri.parse(url + "/transmission/rpc");
    } else {
      _url = Uri.parse(url + path);
    }
  }

  // Future<bool> init() async {
  //   Response? response;
  //   // Check if the server is actually a transmission RPC server and check if the credentials are correct
  //   try {
  //     await http.post(_url, headers: {
  //       'Authorization':
  //           'Basic ${base64Encode(utf8.encode('$_username:$_password'))}',
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //     }).then((_) => response = _);
  //   } catch (e) {
  //     return false;
  //   }
  //   // Wait for the response to be returned, then if x-transmission-session-id is in the headers, then set the session id to the value of the header and return true else return false
  //   if (response!.headers.containsKey('x-transmission-session-id')) {
  //     _sessionId = response!.headers['x-transmission-session-id']!;
  //     return true;
  //   }
  //   return false;
  // }

  // Future<void> _getSessionId() async{
  //   // Make a call to the TransmissionRPC server to aquire the X-Transmission-Session-Id
  //   // Make a request to the transmission RPC synchronously

  //   await http.post(_url, headers: {
  //     'Authorization': 'Basic ${base64Encode(utf8.encode('$_username:$_password'))}',
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //   })
  //   .then((response){
  //     // If the response is 409, then the session id is in the header
  //     if(response.statusCode == 409){
  //       // Get the session id from the header
  //       _sessionId = response.headers['x-transmission-session-id']!;
  //     }
  //   }
  //   );
  // }

  // Future<bool> testCredentials() async {
  //   Response? response;
  //   // Make a call to the TransmissionRPC server to test the credentials
  //   // Make a request to the transmission RPC if the error is 409, then the credentials are correct and return false
  //   Map<String, String> headers = {
  //     'Authorization':
  //         'Basic ${base64Encode(utf8.encode("$_username:$_password"))}',
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //   };
  //   await http.post(_url, headers: headers).then((_) => response = _);

  //   if (response!.statusCode == 409) {
  //     _sessionId = response!.headers['x-transmission-session-id']!;
  //     return true;
  //   }

  //   return response!.statusCode != 401;
  // }

  // Method that returns the status of the server as a Future<Response>
  Future<Status> ping() async {
    // Make a call to the TransmissionRPC server to make sure there is no issues with the details of the server and if not return the status of the server and possible advice as a Status object
    // Make a request to the transmission RPC
    Response response;
    String help = "";

    Map<String, String> headers = {
      'Authorization':
          'Basic ${base64Encode(utf8.encode("$_username:$_password"))}',
      'x-transmission-session-id': '$_sessionId',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      response =
          await http.post(_url, headers: headers).then((_) => response = _);
      // Check to make sure the server is a transmission RPC server and if not send a Status object saying that the server is not a transmission RPC server
      // if (response.body )
    } catch (e) {
      // If the JSON is not valid, then the server is not a transmission RPC server
      if (e is FormatException) {
        return Status(0, e.toString(), API.transmission,
            "The server is not a transmission RPC server");
      }

      return (Status(0, e.toString(), API.transmission,
          "Could not connect to server. Please check your connection"));
    }
    if (response.statusCode == 409) {
      if (!response.headers.containsKey('x-transmission-session-id')) {
        return Status(
          response.statusCode,
          response.body,
          API.transmission,
          "The server is not a transmission RPC server",
        );
      }

      _sessionId = response.headers['x-transmission-session-id']!;

      return ping();
    }
    try {
      final Map jsonResult = jsonDecode(response.body);

      if (!jsonResult.containsKey('arguments') ||
          !jsonResult.containsKey('result')) {
        return Status(0, response.body, API.transmission,
            "Not a valid transmission RPC server");
      }
    } catch (e) {
      return Status(0, e.toString(), API.transmission,
          "Not a valid transmission RPC server");
    }
    return Status(response.statusCode, response.body, API.transmission, help);
  }

  Future<Response> _makeRequest(
      String method, Map<String, dynamic> arguments) async {
    // Send the request and return the response
    Response? response;
    // Make a request to the transmission RPC
    // Make a map that will hold the headers

    Map<String, String> headers = {
      'Authorization':
          'Basic ${base64Encode(utf8.encode("$_username:$_password"))}',
      'x-transmission-session-id': '$_sessionId',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    //Create the json request body
    Map<String, dynamic> body = {
      'method': method,
      'arguments': arguments,
    };

    await http
        .post(_url, headers: headers, body: jsonEncode(body))
        .then((_) => response = _);

    if (response!.statusCode == 409) {
      // Get the session id from the header
      _sessionId = response!.headers['x-transmission-session-id']!;
      // Call itself again
      return await _makeRequest(method, arguments);
    }

    return response!;
  }

  /// Torrent Mutator
  ///
  /// - [id] The id of the torrent
  /// - [arguments] The arguments to change
  ///
  /// Availible options:
  ///
  ///      - bandwidthPriority : int
  ///      - downloadLimit : int
  ///      - downloadLimited : bool
  ///      - files-wanted : List<int>
  ///      - files-unwanted : List<int>
  ///      - honorsSessionLimits : bool
  ///      - ids : List<int>
  ///      - location : string
  ///      - peer-limit : int
  ///      - priority-high : List<int>
  ///      - priority-low : List<int>
  ///      - priority-normal : List<int>
  ///      - queuePosition : int
  ///      - seedIdleLimit : int
  ///      - seedIdleMode : int
  ///      - seedRatioLimit : double
  ///      - seedRatioMode : int
  ///      - sequentialDownload : bool
  ///      - trackerAdd : List<String>
  ///      - trackerRemove : List<int>
  ///      - trackerReplace : List<int>
  ///      - trackerList : String
  ///      - uploadLimit : int
  ///      - uploadLimited : bool

  Future<Map<String, dynamic>> setTorrent(
      List<int> id, Map<String, dynamic> arguments) async {
    Response? res;
    // Make a map that will hold the arguments
    Map<String, dynamic> args = {
      'ids': id,
      'arguments': arguments,
    };
    await _makeRequest('torrent-set', args).then((_) => res = _);
    // Make the request as a map
    return jsonDecode(res!.body)['arguments'];
  }

  Future<Map<String, dynamic>> addTorrent(
      Map<String, dynamic> arguments) async {
    Response? res;
    // Make a map that will hold the arguments
    Map<String, dynamic> args = {
      'arguments': arguments,
    };
    await _makeRequest('torrent-add', args).then((_) => res = _);
    // Make the request as a map
    return jsonDecode(res!.body)['arguments'];
  }

  Future<Map<String, dynamic>> removeTorrent(List<int> id,
      {bool deleteLocalData = false}) async {
    Response? res;
    // Make a map that will hold the arguments
    Map<String, dynamic> arguments = {
      'ids': id,
      'delete-local-data': deleteLocalData,
    };
    await _makeRequest('torrent-remove', arguments).then((_) => res = _);
    // Make the request as a map
    return jsonDecode(res!.body)['arguments'];
  }

  /// Torrent Accessor
  ///
  /// - [id] The id of the torrent
  ///
  ///     Returns a map of the torrent details
  Future<Map<String, dynamic>> getTorrentSingle(int id) async {
    Response? res;
    // Make a map that will hold the arguments
    Map<String, dynamic> arguments = {
      'ids': id,
      'fields': [
        'activityDate',
        'addedDate',
        'bandwidthPriority',
        'comment',
        'corruptEver',
        'creator',
        'dateCreated',
        'desiredAvailable',
        'doneDate',
        'downloadDir',
        'downloadedEver',
        'downloadLimit',
        'downloadLimited',
        'error',
        'errorString',
        'eta',
        'etaIdle',
        'files',
        'fileStats',
        'hashString',
        'haveUnchecked',
        'haveValid',
        'honorsSessionLimits',
        'id',
        'isFinished',
        'isPrivate',
        'isStalled',
        'leftUntilDone',
        'magnetLink',
        'manualAnnounceTime',
        'maxConnectedPeers',
        'metadataPercentComplete',
        'name',
        'peer-limit',
        'peers',
        'peersConnected',
        'peersFrom',
        'peersGettingFromUs',
        'peersSendingToUs',
        'percentDone',
        'pieces',
        'pieceCount',
        'pieceSize',
        'priorities',
        'queuePosition',
        'rateDownload',
        'rateUpload',
        'recheckProgress',
        'secondsDownloading',
        'secondsSeeding',
        'seedIdleLimit',
        'seedIdleMode',
        'seedRatioLimit',
        'seedRatioMode',
        'sizeWhenDone',
        'startDate',
        'status',
        'trackers',
        'trackerStats',
        'totalSize',
        'torrentFile',
        'uploadedEver',
        'uploadLimit',
        'uploadLimited',
        'uploadRatio',
        'wanted',
        'webseeds',
        'webseedsSendingToUs'
      ]
    };

    await _makeRequest('torrent-get', arguments).then((_) => res = _);
    // Make the request as a map
    return jsonDecode(res!.body)['arguments']['torrents'][0];
  }

  Future<List> getTorrentMultiple({List<int> ids = const []}) async {
    // Make a map that will hold the arguments
    Map<String, dynamic> arguments = {
      'fields': [
        'activityDate',
        'addedDate',
        'bandwidthPriority',
        'comment',
        'corruptEver',
        'creator',
        'dateCreated',
        'desiredAvailable',
        'doneDate',
        'downloadDir',
        'downloadedEver',
        'downloadLimit',
        'downloadLimited',
        'error',
        'errorString',
        'eta',
        'etaIdle',
        'files',
        'fileStats',
        'hashString',
        'haveUnchecked',
        'haveValid',
        'honorsSessionLimits',
        'id',
        'isFinished',
        'isPrivate',
        'isStalled',
        'leftUntilDone',
        'magnetLink',
        'manualAnnounceTime',
        'maxConnectedPeers',
        'metadataPercentComplete',
        'name',
        'peer-limit',
        'peers',
        'peersConnected',
        'peersFrom',
        'peersGettingFromUs',
        'peersSendingToUs',
        'percentDone',
        'pieces',
        'pieceCount',
        'pieceSize',
        'priorities',
        'queuePosition',
        'rateDownload',
        'rateUpload',
        'recheckProgress',
        'secondsDownloading',
        'secondsSeeding',
        'seedIdleLimit',
        'seedIdleMode',
        'seedRatioLimit',
        'seedRatioMode',
        'sizeWhenDone',
        'startDate',
        'status',
        'trackers',
        'trackerStats',
        'totalSize',
        'torrentFile',
        'uploadedEver',
        'uploadLimit',
        'uploadLimited',
        'uploadRatio',
        'wanted',
        'webseeds',
        'webseedsSendingToUs'
      ]
    };

    if (ids.isNotEmpty) {
      arguments['ids'] = ids;
    }

    return _makeRequest('torrent-get', arguments)
        .then((_) => jsonDecode(_.body)['arguments']['torrents']);
  }

  Future<List<Torrent>> getAllTorrents() async {
    List<Torrent> torrents = [];
    List<dynamic> map = await getTorrentMultiple();

    for (Map<String, dynamic> torrent in map) {
      TorrentStatus state = TorrentStatus.values[torrent['status']];

      if (state == TorrentStatus.verifying) {
        torrent['percentDone'] = torrent['recheckProgress'];
      }

      torrents.add(Torrent(
          torrent['name'],
          state,
          ((torrent['sizeWhenDone'] * torrent['percentDone']).toDouble())
              .toInt(),
          torrent['rateDownload'],
          torrent['uploadedEver'],
          torrent['rateUpload'],
          torrent['sizeWhenDone'],
          torrent['percentDone'].toDouble(),
          Duration(seconds: torrent['eta']),
          torrent['peersConnected']));
    }
    return torrents;
  }

  Map<String, dynamic> toMap() {
    return {
      "api": "transmission",
      "domain": _url.toString(),
      "user": _username,
      "pass": _password,
    };
  }
}


  //  print(await rpc.getTorrentMultiple());
  // Print the names of all the torrents active on the server
  // List<dynamic> map = await rpc.getTorrentMultiple();
  // for (var i in map) {
  //   print(i['name']);
  // }

  // List<Map<String, dynamic>> map = await rpc.getTorrentMultiple();
  // for(var i in map){
  //   print(i['name']);
  // }
  // print(map['name']);

