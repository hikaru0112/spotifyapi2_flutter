import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uni_links/uni_links.dart';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

//use  getInitialUri()
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String playlist_id = "6SGHCs2wPfMwqSF4CPf55P";
  StreamSubscription<Uri> _subscription;
  String verifier;
  String ch;
  Map _data;
  Map token_j;
  @override
  // ignore: must_call_super
  void initState() {
    _subscription = getUriLinksStream().listen((Uri uri) async {
      print("get");
      print(uri);
      final str = uri.toString().substring(
          uri.toString().indexOf("code") + 5, uri.toString().indexOf("&state"));

      Map<String, String> bodyj = {
        "client_id": "",
        "grant_type": "authorization_code",
        "code": str,
        "redirect_uri": Uri.parse("apical://spt").toString(),
        "code_verifier": verifier
      };

      Map<String, String> headj = {"application": "x-www-form-urlencoded"};
      Response res = await post("https://accounts.spotify.com/api/token",
          body: bodyj, headers: headj);
      print(res.body);
      final jsonres = json.decode(res.body);
      token_j = jsonres;
      Map<String, String> head = {
        "Authorization": "Bearer ${token_j["access_token"]}"
      };
      Response datares = await get(
          "https://api.spotify.com/v1/playlists/$playlist_id/tracks",
          headers: head);
      final spotify_json = json.decode(datares.body);
      _data = spotify_json;
      itemcount = _data['items'].length;
      print(spotify_json);
      setState(() {});
    });
  }

  // ignore: missing_return
  Future<String> getConnection() async {
    verifier = randomString(64);
    print("aaa" + verifier);
    ch = challenge(verifier);
    print(ch);
    String pt = "apical://spt";
    print(Uri.parse(pt));
    String url =
        "https://accounts.spotify.com/authorize?response_type=code&client_id=&redirect_uri=${Uri.parse(pt)}&state=e21392da45dbf4&scope=user-follow-modify&state=e21392da45dbf4&code_challenge=$ch&code_challenge_method=S256";
    print(url);
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
    //Response res = await get(url);
    //print(res.body.toString());
  }

  String randomString(int length) {
    const _randomChars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    const _charsLength = _randomChars.length;

    final rand = new Random.secure();
    final codeUnits = new List.generate(
      length,
      (index) {
        final n = rand.nextInt(_charsLength);
        return _randomChars.codeUnitAt(n);
      },
    );
    return new String.fromCharCodes(codeUnits);
  }

  String challenge(String verifier) {
    var bytes = utf8.encode(verifier);
    var digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll("=", "");
  }

  int _counter = 0;
  int itemcount = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
        children: <Widget>[
          TextButton(onPressed: getConnection, child: Text("aaa")),
          Container(
            height: 700,
            child: RefreshIndicator(
              onRefresh: () async {
                print('Loading New Data');


              },
              child: ListView.builder(
                itemCount: itemcount,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    child: Card(
                      color: Colors.orangeAccent,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("test"),
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 100),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                    _data["items"][index]['track']['name']),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(50),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(_data["items"][index]
                                            ['track']['album']['images'][1]
                                        ['url'])),
                              ),
                            ),
                          ]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Invoke "debug painting" (press "p" in the console, choose the
        // "Toggle Debug Paint" action from the Flutter Inspector in Android
        // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
        // to see the wireframe for each widget.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
