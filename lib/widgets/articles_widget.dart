import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArticlesWidget extends StatefulWidget {

  @override
  _ArticlesWidgetState createState() => _ArticlesWidgetState();
}

class _ArticlesWidgetState extends State<ArticlesWidget>{

  List articles;

  @override
  void initState() {
    super.initState();
    loadArticles();
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Qiita Articles',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Qiita Articles'),
          ),
          body: ListView.builder(
            itemCount: articles == null ? 0 : articles.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Row(
                  children: <Widget>[
                    new Text(
                      articles[index]['title'],
                      style: new TextStyle(fontSize:18.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w300,),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(48.0),
                    )
                  ],
                ),
              );
            },
          ),
        )
    );
  }

  Future loadArticles() async {
    http.Response response = await http.get('https://qiita.com/api/v2/items?page=1&per_page=20');
    List data = json.decode(response.body);
    setState(() {
      articles = data;
    });
  }
}

class Article {
  final int id;
  final String title;
  final String url;

  Article({this.id, this.title, this.url});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      url: json['url'],
    );
  }
}