import 'package:live_musician/music_sheet_reader.dart';
import 'package:live_musician/file_picker.dart';
import 'package:live_musician/pdf_reader.dart';
import 'package:flutter/material.dart';
import 'package:live_musician/home_page.dart';

void main() => runApp(LiveMusician());

class LiveMusician extends StatelessWidget {
  
  final String appBarTitle = 'Live Musician';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Musician App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: HomePage(title: this.appBarTitle),
      routes: {
        '/LiveMusicianMusicalSheets': (context) => LiveMusicianMusicalSheets(),
        '/PDFReader': (context) => PDFReader(),
        '/FileReader': (context) => LiveMusicianFilePicker(),
      }
    );
  }
}
