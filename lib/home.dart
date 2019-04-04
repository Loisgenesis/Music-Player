import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_player/data.dart';
import 'package:music_player/my_colors.dart';
import 'package:music_player/my_strings.dart';
import 'package:music_player/single_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xml2json/xml2json.dart';
import 'package:url_launcher/url_launcher.dart';

const double _kFlexibleSpaceMaxHeight = 280.0;

class _BackgroundLayer {
  _BackgroundLayer({int level, double parallax})
      : parallaxTween = new Tween<double>(begin: 0.0, end: parallax);
  final Tween<double> parallaxTween;
}

final List<_BackgroundLayer> _kBackgroundLayers = <_BackgroundLayer>[
  new _BackgroundLayer(level: 0, parallax: _kFlexibleSpaceMaxHeight),
  new _BackgroundLayer(level: 1, parallax: _kFlexibleSpaceMaxHeight),
  new _BackgroundLayer(level: 2, parallax: _kFlexibleSpaceMaxHeight / 2.0),
  new _BackgroundLayer(level: 3, parallax: _kFlexibleSpaceMaxHeight / 4.0),
  new _BackgroundLayer(level: 4, parallax: _kFlexibleSpaceMaxHeight / 2.0),
  new _BackgroundLayer(level: 5, parallax: _kFlexibleSpaceMaxHeight)
];

class _AppBarBackground extends StatelessWidget {
  const _AppBarBackground({Key key, this.animation, this.imageUrl, this.text})
      : super(key: key);

  final Animation<double> animation;
  final String imageUrl;
  final String text;

  @override
  Widget build(BuildContext context) {
    Size query = MediaQuery.of(context).size;
    return new AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return new Stack(
              children: _kBackgroundLayers.map((_BackgroundLayer layer) {
            return new Positioned(
              top: -layer.parallaxTween.evaluate(animation),
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: new CachedNetworkImage(
                imageUrl: imageUrl,
                height: query.height / 2,
                fit: BoxFit.cover,
              ),
            );
          }).toList());
        });
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  var _isRequestSent = true;
  var _isRequestFailed = false;
  var _isRequestConnection = false;
  Data currentData;
  List<Data> dataList = [];
  String errorMessage;
  Xml2Json xml2json = new Xml2Json();
  String imageUrl;
  String title;
  String link;
  int count = 0;
  StreamSubscription streamSubscription;
  AudioPlayer _audioPlayer;

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  var actionIcon = "assets/images/pause.png";
  @override
  Widget build(BuildContext context) {
    count = 0;
    Size query = MediaQuery.of(context).size;
    return new Scaffold(
        backgroundColor: Colors.white,
        body: _isRequestSent
            ? _getProgressBar()
            : _isRequestFailed || _isRequestConnection
                ? retryButton()
                : dataList.isEmpty
                    ? showNoData()
                    : RefreshIndicator(
                        child: new CustomScrollView(
                          slivers: <Widget>[
                            new SliverAppBar(
                              backgroundColor: MyColors.colorPrimary,
                              pinned: true,
                              titleSpacing: 0.0,
                              expandedHeight: query.height / 2,
                              centerTitle: false,
                              flexibleSpace: new FlexibleSpaceBar(
                                title: new InkWell(
                                  onLongPress: _launchURL,
                                  child: new Text(
                                    title,
                                  ),
                                ),
                                background: new _AppBarBackground(
                                  animation: kAlwaysDismissedAnimation,
                                  imageUrl: imageUrl,
                                ),
                              ),
                            ),
                            new SliverList(
                                delegate: new SliverChildListDelegate(
                                    getCompleteUI())),
                          ],
                        ),
                        onRefresh: refreshList,
                      ),
        bottomNavigationBar: currentData == null
            ? SizedBox()
            : new Container(
                height: 60.0,
                child: new Row(children: <Widget>[
                  Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                            currentData.itunesImage,
                          ),
                          fit: BoxFit.cover),
                    ),
                  ),
                  new SizedBox(
                    width: 10.0,
                  ),
                  new Expanded(
                    child: new Text(
                      currentData.title.replaceAll(r"\", r''),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                  )
                ])));
  }

  Future<Null> refreshList() async {
    dataList.clear();
    getData();
    return null;
  }

  List<Widget> getCompleteUI() {
    List<Widget> widgets = [];
    for (var i = 0; i < dataList.length; i++) {
      count += 1;
      widgets.add(new Container(
        child: _getCardItems(i, count),
      ));
    }
    return widgets;
  }

  Widget _getCardItems(int position, int count) {
    Data datas = dataList[position];
    String newTitle = datas.title.replaceAll(r"\", r'');
    return new InkWell(
      onTap: () {
        singlePage(datas, count);
      },
      child: new Padding(
        padding: EdgeInsets.all(20.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Text(count.toString()),
            new SizedBox(
              width: 10.0,
            ),
            new Expanded(child: new Text(newTitle)),
          ],
        ),
      ),
    );
  }

  void singlePage(Data data, int position) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => new SinglePage(
                data: data,
                index: position,
                dataList: dataList,
                streamSubscription: streamSubscription,
                audioPlayer: _audioPlayer,
                onPlayChange: (value) =>
                    setState(() => this.currentData = value),
              ),
        ));
  }

  Widget placeHolder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: Container(
        height: 300.0,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget showNoData() {
    return Container(
        alignment: Alignment.center,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(
              "No music player found",
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            new SizedBox(
              height: 10.0,
            ),
            new FlatButton(
              onPressed: handleRetry,
              color: Colors.orange,
              textColor: Colors.white,
              child: const Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 20.0),
                child: const Text('RETRY'),
              ),
            ),
          ],
        ));
  }

  Widget _getProgressBar() {
    return new Center(
      child: new Container(
        width: 50.0,
        height: 50.0,
        child: new CircularProgressIndicator(),
      ),
    );
  }

  Widget retryButton() {
    return Container(
        alignment: Alignment.center,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(
              _isRequestConnection
                  ? Strings.networkError
                  : errorMessage == null || errorMessage.isEmpty
                      ? Strings.sthWentWrg
                      : errorMessage,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            new SizedBox(
              height: 10.0,
            ),
            new FlatButton(
              onPressed: handleRetry,
              color: Colors.orange,
              textColor: Colors.white,
              child: const Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 20.0),
                child: const Text('RETRY'),
              ),
            ),
          ],
        ));
  }

  _launchURL() async {
    var url = link;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //this method gets data from api
  void getData() async {
    count = 0;
    try {
      String url =
          'http://feeds.soundcloud.com/users/soundcloud:users:209573711/sounds.rss';
      http.Response response = await http.get(url);
      xml2json.parse(response.body);
      var jsonData = xml2json.toGData();
      Map<String, dynamic> body = json.decode(jsonData);
      imageUrl = body["rss"]["channel"]["image"]["url"]["\$t"];
      title = body["rss"]["channel"]["image"]["title"]["\$t"];
      link = body["rss"]["channel"]["image"]["link"]["\$t"];
      var dat = body["rss"]["channel"]['item'] as List;
      for (var i = 0; i < dat.length; i++) {
        var details = Data.getPostFrmJSONPost(dat[i]);
        dataList.add(details);
      }
      setState(() {
        _isRequestSent = false;
        _isRequestFailed = false;
      });
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      _handleRequestError(e);
    }
  }

  void _handleRequestError(e) {
    var message;
    if (message is TimeoutException) {
      message = Strings.requestTimeOutMsg;
    }
    if (!mounted) {
      return;
    }
    errorMessage = message ??= Strings.sthWentWrg;
    setState(() {
      _isRequestSent = false;
      _isRequestFailed = false;
      _isRequestConnection = e is SocketException;
    });
  }

  void handleRetry() {
    dataList.clear();
    setState(() {
      _isRequestSent = true;
      _isRequestFailed = false;
      _isRequestConnection = false;
    });
    getData();
  }
}
