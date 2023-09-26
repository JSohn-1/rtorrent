import 'package:flutter_test/flutter_test.dart';

import 'package:rtorrent/Status.dart';
import 'package:rtorrent/apis/QTorrent/QTorrent.dart';
import 'package:rtorrent/apis/Torrent.dart';

void main() async {
  String url = 'http://localhost:8080';
  String user = 'admin';
  String pass = 'adminadmin';

  QTorrent qTorrent = QTorrent(url, user, pass);
  group(qTorrent, () {
    test('ping', () async {
      Status status = await qTorrent.ping();

      expect(status.code, 200);
      expect(qTorrent.cookie != "", true);
    });

// TODO: Add test, read test, modify test to use a torrent that is not downloading, remove torrent after test

    test('getTorrents', () async {
      Exception? e;
      List<Torrent> torrents = [];

      try {
        torrents = await qTorrent.getTorrents();
      } on Exception catch (_) {
        e = _;
      }

      expect(e, null);

      expect(torrents[0].name, 'kali-linux-2023.3-installer-amd64.iso');
      expect(torrents[0].state, TorrentStatus.inactive);
      expect(torrents[0].rawState, 'pausedDL');
      expect(torrents[0].size, 4194304000);
    });
  });
}
