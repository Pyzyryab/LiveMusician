import 'package:live_musician/all_songs_list_view.dart';
import 'package:live_musician/utils/file_picker.dart';
import 'package:live_musician/utils/pdf_reader.dart';
import 'package:flutter/material.dart';
import 'package:live_musician/home_page.dart';

void main() => runApp(LiveMusician());

enum Languages {
  ENGLISH,
  SPANISH
}

class LiveMusician extends StatelessWidget {

  static Languages currentLanguage = Languages.ENGLISH;
  
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
        '/LiveMusicianListView': (context) => LiveMusicianListView(),
        '/PDFReader': (context) => PDFReader(),
        '/FileReader': (context) => LiveMusicianFilePicker(),
      }
    );
  }
}
