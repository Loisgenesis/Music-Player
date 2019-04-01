import 'package:flutter/material.dart';
import 'package:music_player/home.dart';
import 'package:music_player/my_colors.dart';
import 'package:audioplayers/audioplayers.dart';

class SinglePage extends StatefulWidget {
  final Data data;
  SinglePage(this.data);
  @override
  SinglePageState createState() => new SinglePageState();
}

class SinglePageState extends State<SinglePage> {

  AudioPlayer audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

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
                  new SizedBox(
                    height: 60.0,
                  ),
                  new Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new IconButton(
                            icon: Icon(Icons.fast_rewind), onPressed: null),
                        new IconButton(
                            icon: Icon(Icons.play_arrow), onPressed: play),
                        new IconButton(
                            icon: Icon(Icons.fast_forward), onPressed: null),
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
  play() async {
    int result = await audioPlayer.play(widget.data.enclosureUrl);
    if (result == 1) {
      // success
    }
  }
}
