// TODO: Change the way the torrents are initallily shown. First load which
// torrents are saved, then async all the individual torrentservers. When the
// list changes update the list.

import 'dart:async';
import 'Transmission.dart';
import '../Status.dart';
import 'Torrent.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// the api
enum API {
  transmission,
  qBittorrent,
}

class Torrents {
  static List<Torrents> servers = [];
  late final API api;
  late final client;
  Duration updateInterval = const Duration(seconds: 1);

  // Constructor for the Torrents class where the paramters are the API
  // and the client object
  Torrents(this.client) {
    if (client is TransmissionRPC) {
      api = API.transmission;
    }
  }

  String get apiString {
    return api.toString().split('.').last;
  }

  Future<Status> ping() async {
    switch (api) {
      case API.transmission:
        return await client.ping();
      default:
        return Status(500, "Not Implemented", api);
    }
  }

  // Static version of the ping method
  static Future<Status> pingStatic(
      API api, String domain, String user, String pass) async {
    switch (api) {
      case API.transmission:
        return await TransmissionRPC(domain, user, pass).ping();
      default:
        return Status(500, "Not Implemented", api);
    }
  }

  Future<List<Torrent>> getAllTorrents() async {
    switch (api) {
      case API.transmission:
        List torrents = await client.getTorrentMultiple();
        List<Torrent> newTorrents = [];
        for (Map<String, dynamic> torrent in torrents) {
          Stat state = Stat.stopped;
          if (torrent['status'] == 0) {
            state = Stat.stopped;
          } else if (torrent['status'] == 1) {
            state = Stat.queuedToVerify;
          } else if (torrent['status'] == 2) {
            state = Stat.verifying;
          } else if (torrent['status'] == 3) {
            state = Stat.queuedToDownload;
          } else if (torrent['status'] == 4) {
            state = Stat.downloading;
          } else if (torrent['status'] == 5) {
            state = Stat.queuedToSeed;
          } else if (torrent['status'] == 6) {
            state = Stat.seeding;
          }

          // If the torrent is being verified, the progress is the recheckProgress
          // Otherwise, it is the percentDone

          if (state == Stat.verifying) {
            torrent['percentDone'] = torrent['recheckProgress'];
          }

          newTorrents.add(Torrent(
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

        return newTorrents;
      default:
        return [];
    }
  }

  static Future<bool> loadSavedTorrents() async {
    print(join('${await getDatabasesPath()}torrents.db'));
    var db = await openDatabase(join(await getDatabasesPath(), 'torrents.db'),
        version: 1, onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE IF NOT EXISTS torrents(api TEXT, domain TEXT, user TEXT, pass TEXT)');
    });
    await db.execute(
        'CREATE TABLE IF NOT EXISTS torrents(api TEXT, domain TEXT, user TEXT, pass TEXT)');
    List<Map<String, dynamic>> maps = await db.query('torrents');
    await db.close();

    for (Map<String, dynamic> map in maps) {
      switch (map['api']) {
        case 'transmission':
          servers.add(Torrents(
              TransmissionRPC(map['domain'], map['user'], map['pass'])));
          break;
        default:
          break;
      }
    }
    return true;
  }

  static Future<void> saveTorrentServer(
      API api, String domain, String user, String pass) async {
    var TorrentServer;
    switch (api) {
      case API.transmission:
        TorrentServer = TransmissionRPC(domain, user, pass);
        break;
      default:
        break;
    }

    var db = await openDatabase('torrents.db');
    await db.insert('torrents', TorrentServer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.close();
  }

  Map<String, dynamic> toMap() {
    return {
      'api': apiString,
      'domain': client.domain,
      'user': client.user,
      'pass': client.pass,
    };
  }
}

// This is the class which will be a vertical scrollable list of the TorrentBox
// widgets. It will be passed a Torrents object and will call the getTorrents()
// method which will return a Future<List<Torrent>>. It will also have a button
// to add a torrent. It will update every second

class TorrentList extends StatefulWidget {
  const TorrentList({super.key, required this.server});

  final Torrents server;

  @override
  _TorrentListState createState() => _TorrentListState();
}

class _TorrentListState extends State<TorrentList> {
  late Future<List<Torrent>> torrents;
  // Make the list of torrents update every second
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    torrents = widget.server.getAllTorrents();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        torrents = widget.server.getAllTorrents();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Torrent>>(
      future: torrents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(title: const Text("Torrents")),
              body: Container(
                  color: const Color.fromARGB(255, 20, 20, 20),
                  // padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Container(
                          padding: const EdgeInsets.all(8),
                          child: TorrentBoxPortrait(
                              torrent: snapshot.data![index]));
                    },
                  )));
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

// Box which will contain the torrent server information and will attempt to
// use the ping() method which is of type Future<bool>. It will have the type of
// server, followed by a colon and the status code (Which comes from the Status
// object returned from the future method),  and a box which will
// be green if the status object's success paramter is true, and red if it is
// false. This box will be clickable and when clicked take the user to the
// ErrorPage and will use the inkwell widget to make it clickable.

class ServerBox extends StatelessWidget {
  const ServerBox({super.key, required this.server});

  final Torrents server;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Status>(
      future: server.ping(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                // If the server is not responding, then the user will be taken
                // to the ErrorPage with the status object passed to it. but if
                // the server is responding, then the user will be taken to the
                // TorrentsPage with the server object passed to it.

                MaterialPageRoute(
                  builder: (context) => snapshot.data!.success
                      ? TorrentList(server: server)
                      : ErrorPage(status: snapshot.data!),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text('${server.apiString}: ${snapshot.data!.code}'),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: snapshot.data!.success ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
