import 'package:flutter_test/flutter_test.dart';

import 'package:rtorrent/Status.dart';
import 'package:rtorrent/apis/QTorrent/QTorrent.dart';
import 'package:rtorrent/apis/Torrent.dart';
import 'test_helper.dart';
import 'package:collection/collection.dart';

void main() async {
  String url = 'http://localhost:8080';
  String user = 'admin';
  String pass = 'adminadmin';

  QTorrent qTorrent = QTorrent(url, user, pass);
  group('basic qtorrent functions', () {
    test('ping', () async {
      Status status = await qTorrent.ping();

      expect(status.code, 200);
      expect(qTorrent.cookie != "", true);
    });

    test('getTorrents', () async {
      Exception? e;

      try {
        await qTorrent.getTorrents();
      } on Exception catch (_) {
        e = _;
      }

      expect(e, null);
    });
  });
  group('Adding torrent (individual)', () {
    setUp(() async {
      await qTorrent.ping();
    });

    test('addTorrentByURLSingle', () async {
      final response = await qTorrent.addTorrentByURLSingle(
        TestHelper.url,
        paused: true,
        category: 'movies',
        skipCheck: 'true',
        rename: 'addTorrentByURLSingle',
        upLimit: '100',
        dlLimit: '200',
        autoTMM: 'true',
        sequentialDownload: 'true',
        firstLastPiecePrio: 'true',
      );

      expect(response.statusCode, equals(200));
    });

    test('readTorrents', () async {
      await Future.delayed(const Duration(seconds: 1));
      Torrent? torrent;
      List<Torrent> torrents = [];

      torrents = await qTorrent.getTorrents();

      torrent = torrents.firstWhereOrNull((element) {
        return element.name == 'addTorrentByURLSingle';
      });

      expect(torrent, isNotNull);
    });

    test('renameTorrents', () async {
      await Future.delayed(const Duration(seconds: 1));
      Torrent? torrent;
      List<Torrent> torrents = [];

      torrents = await qTorrent.getTorrents();

      torrent = torrents.firstWhereOrNull((element) {
        return element.name == 'addTorrentByURLSingle';
      });

      expect(torrent, isNotNull);

      if (torrent != null) {
        await qTorrent.rename(torrent.id, 'renamed');
      }

      await Future.delayed(const Duration(seconds: 1));
      torrents = await qTorrent.getTorrents();

      torrent = torrents.firstWhereOrNull((element) {
        return element.name == 'renamed';
      });

      expect(torrent, isNotNull);
    });

    test('removeTorrents', () async {
      await Future.delayed(const Duration(seconds: 1));
      Torrent? torrent;
      List<Torrent> torrents = [];

      torrents = await qTorrent.getTorrents();

      torrent = torrents.firstWhereOrNull((element) {
        return element.name == 'renamed';
      });

      expect(torrent, isNotNull);

      Status? response;

      if (torrent != null) {
        response = await qTorrent.removeTorrent(torrent.id, true);
      }

      await Future.delayed(const Duration(seconds: 1));
      torrents = await qTorrent.getTorrents();

      torrent = torrents.firstWhereOrNull((element) {
        return element.name == 'addTorrentByURLSingle';
      });

      expect(torrent, isNull);
      expect(response, isNotNull);
      if (response != null) {
        expect(response.code, equals(200));
      }
    });
  });
}
