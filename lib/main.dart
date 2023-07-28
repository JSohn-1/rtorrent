import 'dart:async';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:rtorrent/login.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'apis/TorrentServer.dart';
// import 'Login.dart';

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

// Home Page while will have a list of all the pages, which are the torrents
// with a button to add a new torrent

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
          FutureBuilder(
              future: Torrents.loadSavedTorrents(),
              builder: (context, snapshot) {
                // Once the data is loaded, return a scrollable list of all the torrent which is the Serverlist() widget
                if (snapshot.hasData) {
                  return const Serverlist();
                } else {
                  // If the data is not loaded, return a loading screen
                  return const Center(child: CircularProgressIndicator());
                }
              }),
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

// This is the serverlist that will be displayed on the home page. It will list all the torrents in the form of serverBox widgets. This will use the data from the static field Torrents.servers, which is a list of all the torrents. It will also listen to the ServerListNotifier() which will notify it when the list of torrents is updated. When the user swipes down, it will refresh the list by recalling the ping() method for each torrent

class Serverlist extends StatefulWidget {
  const Serverlist({super.key, required this.loginNotifier});

  final ServerListNotifier loginNotifier;

  @override
  _ServerlistState createState() => _ServerlistState();
}

class _ServerlistState extends State<Serverlist> {
  late List<Torrents> servers;
  final ServerListNotifier serverListNotifier = ServerListNotifier();

  @override
  void initState() {
    super.initState();
    servers = Torrents.servers;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: serverListNotifier,
        builder: (BuildContext context, Widget? child) {
          print("uupdating");
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                // Call the ping() method for each torrent and rebuild the list
                for (Torrents server in servers) {
                  server.ping();
                }
              });
            },
            child: ListView.builder(
              itemCount: servers.length,
              itemBuilder: (context, index) {
                return ServerBox(server: servers[index]);
              },
            ),
          );
        });
  }
}
