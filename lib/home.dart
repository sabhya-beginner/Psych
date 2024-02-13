import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _urlController = TextEditingController();
  String _result = '';

  Future<void> checkUrlSafety(String url) async {
    const apiKey = 'AIzaSyBsycPkLrWRh392DRygcaxfgD2plVHZ3g4';
    const apiUrl =
        'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$apiKey';
    final body = json.encode({
      'client': {'clientId': 'flutter-app', 'clientVersion': '1.0.0'},
      'threatInfo': {
        'threatTypes': [
          'MALWARE',
          'SOCIAL_ENGINEERING',
          'UNWANTED_SOFTWARE',
          'POTENTIALLY_HARMFUL_APPLICATION'
        ],
        'platformTypes': ['ANY_PLATFORM'],
        'threatEntryTypes': ['URL'],
        'threatEntries': [
          {'url': url}
        ]
      }
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['matches'] != null && data['matches'].isNotEmpty) {
          setState(() {
            _result =
                'Potentially Harmful'; // URL is flagged as potentially harmful
          });
        } else {
          setState(() {
            _result = 'Legitimate'; // URL is considered safe
          });
        }
      } else {
        setState(() {
          _result =
              'Error: ${response.reasonPhrase}'; // Error occurred while checking URL safety
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e'; // Catch and display any other errors
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake & Spurious URL Detector'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.0), // Adjust the horizontal padding
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _result = ''; // Clear the result string
                    });
                    _urlController.clear(); // Clear the text field
                  },
                  child: const Text('Reload'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String url = _urlController.text;
                    checkUrlSafety(url);
                  },
                  child: const Text('Detect'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Text(
              'Result: $_result',
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
