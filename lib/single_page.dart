import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_player/data.dart';
import 'package:music_player/my_colors.dart';
import 'package:audioplayers/audioplayers.dart';

enum PlayerState { stopped, playing, paused }

class SinglePage extends StatefulWidget {
  final Data data;
  final int index;
  final List<Data> dataList;
  final StreamSubscription streamSubscription;
  final AudioPlayer audioPlayer;
  final ValueChanged<Data> onPlayChange;

  SinglePage(
      {@required this.data,
      @required this.index,
      @required this.dataList,
      @required this.streamSubscription,
      @required this.audioPlayer,
      @required this.onPlayChange});

  @override
  State<StatefulWidget> createState() {
    return new SinglePageState(
        data, index, dataList, onPlayChange, streamSubscription, audioPlayer);
  }
}

class SinglePageState extends State<SinglePage> {
  Data data;
  int index;
  List<Data> dataList;
  AudioPlayer audioPlayer;
  ValueChanged<Data> onPlayChange;
  StreamSubscription streamSubscription;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;
  bool check;
  PlayerState _playerState = PlayerState.stopped;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';
  var actionIcon = "assets/images/play.png";
  SinglePageState(this.data, this.index, this.dataList, this.onPlayChange,
      this.streamSubscription, this.audioPlayer);

  @override
  void initState() {

    super.initState();
    _initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    String newTitle = data.title.replaceAll(r"\", r'');
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
                      data.itunesImage,
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

  next() async {
    audioPlayer.stop();
    if (mounted) {
      setState(() {
        int i = ++index;
        if (i >= dataList.length) {
          i = index = 0;
        }
        updatePage(i);
      });
    }
  }

  prev() async {
    audioPlayer.stop();
    if (mounted) {
      setState(() {
        int i = --index;
        if (i < 0) {
          index = 0;
          i = index;
        }
        updatePage(i);
      });
    }
  }

  void updatePage(int index) {
    index = index;
    data = dataList[index];
    setState(() {
      this.actionIcon = "assets/images/pause.png";
    });
    audioPlayer.play(data.enclosureUrl);
    onPlayChange(dataList[index]);
  }

  void _initAudioPlayer() {
    audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    streamSubscription = audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    streamSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });

    streamSubscription = audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      if (mounted) {
        setState(() {
          _position = _duration;
          int i = ++index;
          data = dataList[i];
        });
      }
    });

    streamSubscription = audioPlayer.onPlayerError.listen((msg) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _duration = new Duration(seconds: 0);
          _position = new Duration(seconds: 0);
        });
      }
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _audioPlayerState = state;
        });
      }
    });
  }

  play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result =
        await audioPlayer.play(data.enclosureUrl, position: playPosition);
    if (result == 1) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.playing;
        });
      }
      onPlayChange(data);
    }
    return result;
  }

  pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) if (result == 1) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.paused;
        });
      }
      onPlayChange(data);
    }
    return result;
  }

  stop() async {
    final result = await audioPlayer.stop();
    if (result == 1) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = new Duration();
        });
      }
    }
    return result;
  }

  void _onComplete() {
    next();
  }
}
