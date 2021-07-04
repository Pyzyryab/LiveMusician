import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share/share.dart';

import 'package:live_musician/main.dart';

import '../musical_song.dart';

class PDFReader extends StatefulWidget {
  final String? path;
  final String? title;
  final bool? nightMode;
  final MusicalSong? song;

  PDFReader({Key? key, this.path, this.title, this.nightMode, this.song}) : super(key: key);

  _PDFReaderState createState() => _PDFReaderState();
}

class _PDFReaderState extends State<PDFReader> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  
  MusicalSong? song;
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  bool nightMode = false;

  @override
  void initState() {
    this.nightMode = (widget.nightMode != null) ? widget.nightMode! : false;
    this.song = widget.song;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
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
      body: Stack(
        children: <Widget> [ 
          PDFView(
            nightMode: this.nightMode,
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
        ]
      ),  
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 15,
          ),
          FutureBuilder<PDFViewController>(
            future: _controller.future,
            builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
              if (snapshot.hasData) {
                return FloatingActionButton.extended(
                  heroTag: "btn1",
                  label: Text(
                   (LiveMusician.currentLanguage == Languages.ENGLISH)
                    ? 'First page' : 'Inicio'
                  ),
                  onPressed: () async {
                    await snapshot.data!.setPage(0);
                  },
                );
              }
              return Container();
            },
          ),
          FutureBuilder<PDFViewController>(
            future: _controller.future,
            builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
              if (snapshot.hasData) {
                return FloatingActionButton.extended(
                  heroTag: "btn2",
                  label: Text(
                  (LiveMusician.currentLanguage == Languages.ENGLISH)
                    ? 'Last page' : 'Final'
                  ),
                  onPressed: () async {
                    await snapshot.data!.setPage(pages!);
                  },
                );
              }
              return Container();
            },
          ),
           FutureBuilder<PDFViewController>(
            future: _controller.future,
            builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
              if (snapshot.hasData) {
                return FloatingActionButton.extended(
                  heroTag: "btn3",
                  label: Text(
                  (LiveMusician.currentLanguage == Languages.ENGLISH)
                    ? (!this.nightMode) ? 'Night mode' : 'Day Mode' 
                    : (!this.nightMode) ? 'Modo noche' : 'Modo día'
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => PDFReader(
                            path: widget.path,
                            title: widget.title,
                            nightMode: !this.nightMode,
                          )
                        )); 
                    });
                  }
                );
              }
              return Container();
            },
           )
        ],
      ),
    );
  }
}