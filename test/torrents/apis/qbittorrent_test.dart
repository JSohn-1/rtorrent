import 'package:flutter_test/flutter_test.dart';

import 'package:rtorrent/Status.dart';
import 'package:rtorrent/apis/QTorrent.dart';

void main() async {
  String url = 'http://localhost:8080';
  String user = 'admin';
  String pass = 'adminadmin';

  QTorrent qTorrent = QTorrent(url, user, pass);

  test('ping', () async {
    Status status = await qTorrent.ping();
    expect(status.code, 200);
  });

  test('getTorrents', () async {
    Status status = await qTorrent.getTorrents();
    expect(status.code, 200);
  });
}
