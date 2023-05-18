import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum Stat {
  downloading,
  queuedToDownload,
  paused,
  stopped,
  queuedToVerify,
  verifying,
  queuedToSeed,
  seeding,
}

// The torrent class which will contain all the information about the torrent that is needed for the user
class Torrent {
  late final String name;
  late final String id;
  late final Stat state;
  late final int downloaded;
  late final int downloadSpeed;
  late final int uploaded;
  late final int uploadSpeed;
  late final int size;
  late final double progress;
  late final Duration eta;
  late final int peersConnected;

  Torrent(
      this.name,
      this.state,
      this.downloaded,
      this.downloadSpeed,
      this.uploaded,
      this.uploadSpeed,
      this.size,
      this.progress,
      this.eta,
      this.peersConnected);

  Map<String, List<String>> getSpeed() {
    // Find the speed in the form of GB/s MB/s or KB/s depending on the speed with the number going to one decimal place
    String downspeedUnit = "KB/s";
    String upspeedUnit = "KB/s";
    double downspeed = downloadSpeed / 1000;
    double upspeed = uploadSpeed / 1000;

    // print(downloadSpeed);

    if (downloadSpeed > 100000000) {
      downspeed = downspeed / 1000000;
      downspeedUnit = "GB/s";
    } else if (downspeed > 1000) {
      downspeed = downspeed / 1000;
      downspeedUnit = "MB/s";
    }

    if (uploadSpeed > 100000000) {
      upspeed = upspeed / 1000000;
      upspeedUnit = "GB/s";
    } else if (upspeed > 1000) {
      upspeed = upspeed / 1000;
      upspeedUnit = "MB/s";
    }

    // Round the speed to 1 decimal place
    downspeed = double.parse(downspeed.toStringAsFixed(1));
    upspeed = double.parse(upspeed.toStringAsFixed(1));

    // If the decimal place is 0, remove it
    String findownspeed = downspeed.toString();
    String finupspeed = upspeed.toString();

    // If the decimal place is 0, get the substring without the decimal place
    if (findownspeed.substring(findownspeed.length - 2) == ".0") {
      findownspeed = findownspeed.substring(0, findownspeed.length - 2);
    }

    if (finupspeed.substring(finupspeed.length - 2) == ".0") {
      finupspeed = finupspeed.substring(0, finupspeed.length - 2);
    }

    return ({
      "downspeed": [findownspeed, downspeedUnit],
      "upspeed": [finupspeed, upspeedUnit]
    });
  }
}

// This is the container that will show the details of a torrent. It will have a play/pause/stop icon, title, the current download and upload speed, a circular progress bar, with the prcentage in the middle of the circle. It will also have a button to delete the torrent. It will be passed a Torrent object which will be used to display the information. Another class will have a list of instances of this class

class TorrentBox extends StatelessWidget {
  const TorrentBox({super.key, required this.torrent});

  final Torrent torrent;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: const Color.fromARGB(20, 255, 255, 255),
        ),
        child: Row(children: [
          Container(
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width / 2,
            child: Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 4,
                alignment: Alignment.center,
                child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        double width = 0;

                        if (MediaQuery.of(context).size.width > 1000) {
                          width = (MediaQuery.of(context).size.width / 2) - 170;
                        } else if (MediaQuery.of(context).size.width > 500) {
                          width = 200;
                        } else {
                          width = 100;
                        }

                        return Container(
                          width: width,
                          child: //Flexible(
                              // fit: FlexFit.loose,
                              // child:
                              // constraints: BoxConstraints.,
                              // alignment: Alignment.topCenter,
                              Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: Text(
                                    '${torrent.name}',
                                    overflow: TextOverflow.clip,
                                    maxLines: 3,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                    textAlign: TextAlign.center,
                                  )),
                          // )
                        );
                      }),
                      // This will be the current download and upload speed with a down arrow and up arrow respectively
                      Container(
                          width: 146,
                          height: 40,
                          // child: Flexible(
                          // fit: FlexFit.loose,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download,
                                  size: 40, color: Colors.blue),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(torrent.getSpeed()['downspeed']![0],
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                  Text(torrent.getSpeed()['downspeed']![1],
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.white))
                                ],
                              ),
                              const Icon(Icons.upload,
                                  size: 40, color: Colors.blue),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(torrent.getSpeed()['upspeed']![0],
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                  Text(torrent.getSpeed()['upspeed']![1],
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.white))
                                ],
                              ),
                            ],
                          )
                          // )
                          ),
                      // This will be the progress indicator
                    ])),
          ),
          // This spacer will be used to push the progress bar to the right
          const Spacer(flex: 2),
          SizedBox(
            width: MediaQuery.of(context).size.height / 7,
            height: MediaQuery.of(context).size.height / 7,
            // alignment: Alignment.centerRight,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: MediaQuery.of(context).size.height / 7,
                height: MediaQuery.of(context).size.height / 7,
                child: CircularProgressIndicator(
                  value: torrent.progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey,
                ),
              ),
              // The number should be rounded to one decimal place
              Text('${(torrent.progress * 100).round()}%',
                  style: const TextStyle(fontSize: 20, color: Colors.white)),
            ]),
          ),
          const Spacer(),
          // This will be the button that takes you to the torrent info page
          Container(
              width: 50,
              height: 50,
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TorrentInfo(
                                  torrent: torrent,
                                )));
                  },
                  icon: const Icon(Icons.info_outline,
                      size: 40, color: Colors.blue))),
        ]));
  }
}

// This class will have all the info of a torrent, and will be page with boxes for each metric of the torrent. It will be passed a torrent object which will be used to display the information

class TorrentInfo extends StatelessWidget {
  const TorrentInfo({super.key, required this.torrent});

  final Torrent torrent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(torrent.name),
        ),
        backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        body: SingleChildScrollView(
          child: Column(children: [
            const Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              children: [
                const Padding(padding: EdgeInsets.only(left: 10)),
                Container(
                    height: (MediaQuery.of(context).size.width / 2) - 15,
                    width: (MediaQuery.of(context).size.width / 2) - 15,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color.fromARGB(20, 255, 255, 255)),
                    child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.loose,
                        children: [
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width / 2) * 0.85,
                            height:
                                (MediaQuery.of(context).size.width / 2) * 0.85,
                            child: CircularProgressIndicator(
                              value: torrent.progress,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey,
                            ),
                          ),

                          // The number should be rounded to one decimal place

                          // THe number should be rounded to one decimal place and be centered and use the AutoSizeText widget
                          Container(
                              width: (MediaQuery.of(context).size.width / 6) *
                                  0.80,
                              height: (MediaQuery.of(context).size.width / 6) *
                                  0.80,
                              alignment: Alignment.center,
                              child: FittedBox(
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                  child: Text(
                                    '${(torrent.progress * 100).round()}%',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 100),
                                    textAlign: TextAlign.center,
                                  ))),
                        ])),
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                ),
                Column(children: [
                  Container(
                      alignment: Alignment.center,
                      height: (MediaQuery.of(context).size.width / 4) - 12.5,
                      width: (MediaQuery.of(context).size.width / 2) - 15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color.fromARGB(20, 255, 255, 255)),
                      child: Container(
                        height: (MediaQuery.of(context).size.width / 4) * 1.5,
                        width: (MediaQuery.of(context).size.width / 4) * 1.5,
                        alignment: Alignment.center,
                        child: Text(torrent.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20)),
                      )),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  Container(
                    height: (MediaQuery.of(context).size.width / 4) - 12.5,
                    width: (MediaQuery.of(context).size.width / 2) - 15,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color.fromRGBO(255, 255, 255, 0.078)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Spacer(flex: 2),
                        Icon(
                          size:
                              (((MediaQuery.of(context).size.width - 15) / 10)),
                          Icons.download_rounded,
                          color: Colors.white,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              // height:
                              //     ((MediaQuery.of(context).size.height / 4) - 15) *
                              //         0.4,
                              width:
                                  (((MediaQuery.of(context).size.width - 15) /
                                      35)),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  '${torrent.getSpeed()['downspeed']![0]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              width:
                                  (((MediaQuery.of(context).size.width - 15) /
                                      20)),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  torrent.getSpeed()['downspeed']![1],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          size:
                              (((MediaQuery.of(context).size.width - 15) / 10)),
                          Icons.upload_rounded,
                          color: Colors.white,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width:
                                  (((MediaQuery.of(context).size.width - 15) /
                                      35)),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  '${torrent.getSpeed()['upspeed']![0]}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              width:
                                  (((MediaQuery.of(context).size.width - 15) /
                                      20)),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  torrent.getSpeed()['upspeed']![1],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(flex: 2)
                      ],
                    )
                    /*
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      BoxConstraints cons = BoxConstraints(
                          maxHeight: constraints.maxHeight,
                          maxWidth: constraints.maxWidth / 4.0);

                      // if(constraints.maxHeight)
                      // Align the icons with the text. Size everything to fit the container. If the container becomes too small, place the speed above the units. The order of the items left to right is: download icon, download speed number, download speed unit, upload speed icon, upload speed number, upload speed unit
                      return }*/

                    ,
                  )
                ])
                // ],
                // ),
                ,
                const Padding(padding: EdgeInsets.only(right: 10)),
              ],
            ),
            Row(
              children: [
                Container(
                    height: (MediaQuery.of(context).size.width / 2) * 0.9,
                    width: (MediaQuery.of(context).size.width / 2) * 0.9,
                    color: const Color.fromARGB(245, 255, 255, 255),
                    child: Text('Peers: ${torrent.peersConnected}')),
              ],
            )
          ]),
        ));
  }
}

// This class will wrap a text inside of a fittedbox inside of a container. The container will have be defined by the width and height paramters, and the text will be defined by the text parameter which accepts a Text widget. The text will be centered and will be scaled to fit the container

class FittedText extends StatelessWidget {
  const FittedText({super.key, required this.child, this.width, this.height});

  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: FittedBox(
            alignment: Alignment.center, fit: BoxFit.cover, child: child));
  }
}

void main() {
  Torrent torrent = Torrent("test", Stat.downloading, 0, 900000000, 0,
      800000000, 0, 0, const Duration(seconds: 0), 0);
  print(torrent.getSpeed()["upspeed"]![0]);
  print(torrent.getSpeed()["upspeed"]![1]);
}
