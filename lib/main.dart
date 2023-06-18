import 'dart:async';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:rtorrent/login.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'apis/Torrent.dart';
import 'apis/TorrentServer.dart';
import 'Status.dart';
// import 'Login.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite_common/sqlite_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineMedium:
              TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Home Page while will have a list of all the pages, which are the torrents with a button to add a new torrent
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: [
          const Serverlist(),
          // A Button to add a new server using th page Login()
          InkWell(
            child: const Icon(Icons.add),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// This is the scrollable list of all the torrents, which will be a list of
// TorrentBoxPortrait widgets. This will call the loadSavedTorrents() method which
// returns a Future<List<Torrents>>. When the user swipes down, it will refresh by recalling the method.

/*
class ServerList extends StatelessWidget {
  const ServerList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Torrents>>(
      future: Torrents.loadSavedTorrents(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ServerBox(server: snapshot.data![index]);
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
*/

class Serverlist extends StatefulWidget {
  const Serverlist({super.key});

  @override
  _ServerlistState createState() => _ServerlistState();
}

class _ServerlistState extends State<Serverlist> {
  late Future<List<Torrents>> servers;

  @override
  void initState() {
    super.initState();
    servers = Torrents.loadSavedTorrents();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: ServerListNotifier(),
        builder: (BuildContext context, Widget? child) {
          return FutureBuilder<List<Torrents>>(
            future: servers,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Scrollabe list of all the torrents. If the user swipes down, it will refresh the list. by recalling the method.
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      servers = Torrents.loadSavedTorrents();
                    });
                  },
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ServerBox(server: snapshot.data![index]);
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          );
        });
  }
}

// This page will be used to add torrent servers. 