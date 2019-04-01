import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/home.dart';
import 'package:music_player/my_colors.dart';
import 'package:music_player/my_strings.dart';



    void main() async {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Strings.appName,
      theme: new ThemeData(
          primaryColor: MyColors.colorPrimary,
          accentColor: MyColors.accentColor,
          fontFamily: Strings.customFont),
      home: new Home()));
}
