import 'package:flutter/material.dart';
import 'dart:async';

import 'apis/TorrentServer.dart';
import 'Status.dart';

class Login extends StatefulWidget {
  Function? callback;
  Login({super.key, required this.callback});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String inputValueDomain = "";
  String inputValueUser = "";
  String inputValuePass = "";
  bool result = false;

  final TextEditingController domain = InputFields.controllerDomain;
  final TextEditingController user = InputFields.controllerUser;
  final TextEditingController pass = InputFields.controllerPass;

  // When the test button is pressed, test the connection to the server
  Future<Status> _test() async {
    Status status = await Torrents.pingStatic(
        API.transmission, domain.text, user.text, pass.text);

    setState(() {
      result = status.success;
    });
    /*
    if (!result) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(status.message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"))
              ],
            );
          });
    }
    */
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Login")),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: const Color.fromARGB(255, 20, 20, 20),
            child: Column(
              children: [
                const Text("Add another torrent server:",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                const Text("Domain (Include http:// or https://)",
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                InputFields(),
                TestButton(
                  test: _test,
                ),
                AddButton(callback: widget.callback!),
                // const InkWell(
                //     child: Text(
                //   "Add",
                //   style: TextStyle(color: Colors.white),
                // )),
              ],
            )));
  }
}

class InputFields extends StatefulWidget {
  static final TextEditingController _controllerName = TextEditingController();
  static final TextEditingController _controllerDomain =
      TextEditingController();
  static final TextEditingController _controllerUser = TextEditingController();
  static final TextEditingController _controllerPass = TextEditingController();

  InputFields({super.key});

  static TextEditingController get controllerName => _controllerName;
  static TextEditingController get controllerDomain => _controllerDomain;
  static TextEditingController get controllerUser => _controllerUser;
  static TextEditingController get controllerPass => _controllerPass;
  @override
  _InputFieldsState createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              controller: InputFields._controllerName,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white),
              ),
              onChanged: (text) {
                setState(() {});
              },
            )),
        const Padding(padding: EdgeInsets.all(10)),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              controller: InputFields._controllerDomain,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                labelText: 'Domain',
                labelStyle: TextStyle(color: Colors.white),
              ),
              onChanged: (text) {
                setState(() {});
              },
            )),
        const Padding(padding: EdgeInsets.all(10)),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              controller: InputFields._controllerUser,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
              ),
              onChanged: (text) {
                setState(() {});
              },
            )),
        const Padding(padding: EdgeInsets.all(10)),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              controller: InputFields._controllerPass,
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
              ),
              onChanged: (text) {
                setState(() {});
              },
            )),
      ],
    );
  }
}

class TestButton extends StatefulWidget {
  final Future<Status> Function() test;

  const TestButton({Key? key, required this.test}) : super(key: key);

  @override
  _TestButtonState createState() => _TestButtonState();
}

// The button that tests the connection to the server which when pressed will will show either a green check or red x to the right of the button
// Immediatly after the button is pressed, the button will be disabled until the test is complete and a loading circle will appear to the right of the button which will disappear when the test is complete
// The button will accept a future status callback which will be the result of the test and will use a future builder to display the result of the test. If the test is successful, a green check will appear to the right of the button. If the test fails, a red x will appear to the right of the button. If the test succeeds, the dialog will not show

class _TestButtonState extends State<TestButton> {
  // The button will be disabled until the test is complete
  bool _disabled = false;
  Status? _status;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            // The button will be disabled until the test is complete
            setState(() {
              _disabled = true;
            });
            // The test will be run
            _status = await widget.test();
            // The button will be enabled
            setState(() {
              _disabled = false;
            });
            // Only show the dialog if there was an error. Once the status is found, show the icon which will be either a green check or red x
            if (!_status!.success) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: Text(
                        'An error occurred: ${_status!.message}, \n ${_status!.help}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: const Text('Test'),
        ),
        // If the button is disabled, a loading circle will appear to the right of the button
        if (_disabled)
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            ),
          )
        else if (_status != null)
          // If the test is complete, an icon will appear to the right of the button. If the test was successful, a green check will appear. If the test failed, a red x will appear
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(
              _status!.success ? Icons.check : Icons.close,
              color: _status!.success ? Colors.green : Colors.red,
            ),
          ),
      ],
    );
  }
}

// Button to add the torrent to the db using the info from the input fields and running the method saveTorrent which accepts a TorrentServer Object and returns a Future<void>

class AddButton extends StatefulWidget {
  Function? callback;
  AddButton({Key? key, required this.callback}) : super(key: key);

  @override
  _AddButtonState createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await Torrents.saveTorrentServer(
            InputFields._controllerDomain.text,
            API.transmission,
            InputFields._controllerDomain.text,
            InputFields._controllerUser.text,
            InputFields._controllerPass.text);
        Navigator.of(context).pop();
        widget.callback!();
        InputFields._controllerDomain.clear();
        InputFields._controllerUser.clear();
        InputFields._controllerPass.clear();
      },
      child: const Text('Add'),
    );
  }
}
