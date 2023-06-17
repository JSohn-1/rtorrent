import 'apis/TorrentServer.dart';
import 'package:flutter/material.dart';

class Status {
  late final int code; // Http Response Code
  late final bool success; // If there were no errors
  late final String message; // Response from the server if one
  late final API api; // Torrent Server type
  late final String help; // Solution to the error

  Status(this.code, this.message, this.api,
      [String help = "", bool success = false]) {
    // Set help based on the error code and advice as to how to fix it based on what it means as per the mozilla docs
    if (help != "") {
      this.help = help;
    } else {
      // If the error code is within the a number range, set the help message to the error code
      if (code >= 100 && code <= 199) {
        this.help = "Informational: $code";
      } else if (code >= 200 && code <= 299) {
        this.help = "Success: $code: no need for further action";
        success = true;
      } else if (code >= 300 && code <= 399) {
        this.help = "Redirection: $code";
      } else if (code >= 400 && code <= 499) {
        this.help = "Client Error: $code";
      } else if (code >= 500 && code <= 599) {
        this.help = "Server Error: $code: Please check your server";
      } else {
        this.help = "Unknown Error: $code";
      }
    }
    this.success = success;
  }
}

// This is the page which will be shown if there is an error when connecting to the server. It will have a button which will allow the user to go back to the home page. It will be passed a Status object which will be used to display the error message.

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.status});

  final Status status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(
              flex: 2,
            ),
            Container(
              // color: Colors.grey,
              child: Text('Error Code: ${status.code}'),
            ),
            Text('${status.message}'),
            Text('${status.help}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

//Parse the status.message html and return a widget that will be inside of the
//ErrorPage

class ErrorPageMessage extends StatelessWidget {
  const ErrorPageMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
