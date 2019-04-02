import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_player/data.dart';
import 'package:music_player/my_colors.dart';
import 'package:audioplayers/audioplayers.dart';

enum PlayerState { stopped, playing, paused }

class SinglePage extends StatefulWidget {
  Data data;
  int index;
  List<Data> dataList;
  SinglePage(this.data, this.index, this.dataList);

  @override
  State<StatefulWidget> createState() {
    return new SinglePageState();
  }
}

class SinglePageState extends State<SinglePage> {
  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription streamSubscription;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';
  var actionIcon = "assets/images/play.png";
  @override
  void initState() {
    print(widget.index);
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String newTitle = widget.data.title.replaceAll(r"\", r'');
    Size query = MediaQuery.of(context).size;
    return new Scaffold(
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: MediaQuery.of(context).padding.top,
            color: MyColors.colorPrimaryDark,
          ),
          Container(
              width: double.infinity,
              height: query.height / 1.7,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                      widget.data.itunesImage,
                    ),
                    fit: BoxFit.cover),
              ),
              child: new Align(
                alignment: Alignment.topLeft,
                child: new IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )),
          new SizedBox(
            height: query.height / 3,
            child: new Padding(
              padding: EdgeInsets.all(20.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    newTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                  new Column(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.all(12.0),
                        child: new Stack(
                          children: [
                            new Slider(
                              onChanged: null,
                              value: 1.0,
                            ),
                            new Slider(
                              value: (_position != null &&
                                      _duration != null &&
                                      _position.inMilliseconds > 0 &&
                                      _position.inMilliseconds <
                                          _duration.inMilliseconds)
                                  ? _position.inMilliseconds /
                                      _duration.inMilliseconds
                                  : 0.0,
                              onChanged: null,
                            ),
                          ],
                        ),
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            _position != null ? _positionText : "0:00:00",
                            style: new TextStyle(fontSize: 20.0),
                          ),
                          new Text(
                            _duration != null ? _durationText : "0:00:00",
                            style: new TextStyle(fontSize: 20.0),
                          ),
                        ],
                      )
                    ],
                  ),
                  new Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new IconButton(
                          icon: new Image.asset("assets/images/backward.png"),
                          onPressed: prev,
                        ),
                        new IconButton(
                            color: Colors.blue,
                            icon: new Image.asset(actionIcon),
                            onPressed: () {
                              setState(() {
                                if (this.actionIcon ==
                                    "assets/images/play.png") {
                                  play();
                                  this.actionIcon = "assets/images/pause.png";
                                } else {
                                  pause();
                                  this.actionIcon = "assets/images/play.png";
                                }
                              });
                            }),
                        new IconButton(
                            icon: new Image.asset("assets/images/forward.png"),
                            onPressed: next),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

   next() async  {
    _audioPlayer.stop();
    setState(() {
      int i = ++widget.index;
      if (i >= widget.dataList.length) {
       i = widget.index = 0;
      }
      updatePage(i);
    });

  }

   prev()  async{
    _audioPlayer.stop();

    setState(() {
      int i = --widget.index;
      if (i < 0) {
        widget.index = 0;
        i = widget.index;
      }
      updatePage(i);
    });
  }

  void updatePage(int index) {
    widget.index = index;
    widget.data = widget.dataList[index];
     setState(() {
      this.actionIcon = "assets/images/pause.png";
    });
    _audioPlayer.play(widget.data.enclosureUrl);
  }

  void _initAudioPlayer() {
    _audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

    streamSubscription =
        _audioPlayer.onDurationChanged.listen((duration) => setState(() {
              _duration = duration;
            }));

    streamSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    streamSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
        int i = ++widget.index;
        widget.data = widget.dataList[i];
      });
    });

    streamSubscription = _audioPlayer.onPlayerError.listen((msg) {
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = new Duration(seconds: 0);
        _position = new Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });
  }

  Future<int> play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(widget.data.enclosureUrl,
        position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    return result;
  }

  Future<int> pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = new Duration();
      });
    }
    return result;
  }

  void _onComplete() {
   next();
  }
}
