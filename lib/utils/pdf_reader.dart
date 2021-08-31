import 'package:flutter/material.dart';
import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:share/share.dart';

import '../musical_song.dart';


class PDFReader extends StatefulWidget {

  final String? path;
  final String? title;
  final bool? nightMode;
  final MusicalSong? song;

  PDFReader({Key? key, this.path, this.title, this.nightMode, this.song}) : super(key: key);
  
  @override
  _PDFReaderState createState() => _PDFReaderState();
}

class _PDFReaderState extends State<PDFReader> {
  
  MusicalSong? song;
  bool _isLoading = true;
  PDFDocument? document;

  @override
  void initState() {
    this.song = widget.song;
    loadDocument();
    super.initState();
  }

  loadDocument() async {
    document = await PDFDocument.fromFile(File(widget.path!));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Center(
          child: Text(widget.title!)
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              //share file
              Share.shareFiles(
                ['${widget.path}'], // paths
                text: '${song!.fileName}, ${song!.genre} shared',
                subject: 'Music sheet created by ${song!.author}'
                );
              },
            ),
          ],
        ),
        body: Center(
          child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(
                document: document!,
                zoomSteps: 1,
                // uncomment below line to preload all pages
                lazyLoad: false,
                // uncomment below line to scroll vertically
                scrollDirection: Axis.vertical,
              ),
        )
      );
  }
}