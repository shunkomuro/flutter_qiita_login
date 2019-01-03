import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_qiita_login/widgets/articles_widget.dart';

void main() => runApp(MyApp());

// FlutterでWebViewを表示する
// https://qiita.com/Horie1024/items/f5eedd485a436f2c0592

// リダイレクト検出とログイン処理
// https://stackoverflow.com/questions/51541258/flutter-login-through-a-webview

// FlutterのNavigatorで画面遷移
// https://qiita.com/granoeste/items/19c119ffc36a016e6223

// Flutterの画面遷移
// https://qiita.com/tatsu/items/38cd85efd93005b95af9

const CLIENT_ID = '';
const CLIENT_SECRET = '';

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qiita Login',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Qiita Login'),
      routes: <String, WidgetBuilder> {
        '/articles': (BuildContext context) => new ArticlesWidget(),
      },
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

  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  String code;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("destroy");
    });

    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
          print("onStateChanged: ${state.type} ${state.url}");
        });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          print("URL changed: $url");
          if (url.startsWith('qiita://logincallback')) {
            RegExp regExp = new RegExp("code=(.*)");
            this.code = regExp.firstMatch(url)?.group(1);
            flutterWebviewPlugin.close();
            login();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      url: 'https://qiita.com/api/v2/oauth/authorize'
          '?client_id=$CLIENT_ID'
          '&client_secret=$CLIENT_SECRET'
          '&state=flutter_qiita_login',
    );
  }

  Future<List> login() async {
    // TODO access token を取得する
    // TODO access token を保存する
    final response =
    await http.get('https://qiita.com/api/v2/items?page=1&per_page=20');

    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacementNamed('/articles');
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }
}

