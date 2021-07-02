import 'package:live_musician/main.dart';
import 'package:live_musician/musical_song.dart';
import 'package:live_musician/utils/pdf_reader.dart';
import 'package:live_musician/utils/extensions.dart';
import 'package:live_musician/utils/languages.dart';


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import 'package:pdf_text/pdf_text.dart';


class LiveMusicianListView extends StatefulWidget {
  LiveMusicianListView({Key? key}) : super(key: key);

  @override
  _LiveMusicianListViewState createState() => _LiveMusicianListViewState();
}

class _LiveMusicianListViewState extends State<LiveMusicianListView> {
  
  int index = 0;
  bool _firstSave = true;

  void _openFileExplorer({
    required bool allowMultiple, 
    required FileType pickingType, 
    required List<String> extension}) async {

      List<PlatformFile>? _paths;
      PDFDoc doc;

      try {
        _paths = (await FilePicker.platform.pickFiles(
          type: pickingType,
          allowMultiple: allowMultiple,
          allowedExtensions: extension)) ?.files;
      } on PlatformException catch (e) {
          print("Unsupported operation" + e.toString());
      } catch (ex) {
          print(ex);
      }

      if (!mounted) return;
      for (var element in _paths!) {
        doc = await PDFDoc.fromPath(element.path!);
        setState(() {
          this.songs.add(MusicalSong(
            fileName: element.name.replaceAll(RegExp(r'.pdf'), '').trim().capitalizeFirstofEach, 
            pdfPath: element.path!, 
            arranger: (doc.info.author != "" && doc.info.author != null) ? doc.info.author! : "Sin datos",
            genre: (doc.info.keywords != [] && doc.info.keywords != null) ? doc.info.keywords![0].capitalize : "...",
          ));
        });
      }
  }

  List<MusicalSong> songs = [
    // MusicalSong(
    //   fileName: "Dolores se llamaba lola", 
    //   pdfPath: '/data/user/0/com.example.LiveMusician/cache/file_picker/120520140951280826 (1).pdf', arranger: "Alberto Cereijo", genre: "Rock"),
    // MusicalSong(
    //   fileName: "Juanita", 
    //   pdfPath: '/data/user/0/com.example.LiveMusician/cache/file_picker/120520140951280826 (1).pdf', arranger: "Yoanni Fonseca", genre: "Rock"),
    // MusicalSong(
    //   fileName: "La morena es to guapa", 
    //   pdfPath: '/data/user/0/com.example.LiveMusician/cache/file_picker/120520140951280826 (1).pdf', arranger: "Yoanni Fonseca", genre: "Rock"),
    // MusicalSong(
    //   fileName: "Pon a mao na cabusiña", 
    //   pdfPath: '/data/user/0/com.example.LiveMusician/cache/file_picker/120520140951280826 (1).pdf', arranger: "Yo", genre: "Batucada"),
    // MusicalSong(
    //   fileName: "Saminamina eh eh", 
    //   pdfPath: '/data/user/0/com.example.LiveMusician/cache/file_picker/120520140951280826 (1).pdf', arranger: "Yo", genre: "Merengue"),
  ];

  String valueText = "";

  Future<void> addMusicalSongAsText(String title, String placeholder) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              // controller: _textFieldController,
              decoration: InputDecoration(hintText: placeholder),
            ),
            actions: <Widget>[
              // ignore: deprecated_member_use
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text(
                  (LiveMusician.currentLanguage == Languages.ENGLISH) ? 'CANCEL' : 'CANCELAR'
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              // ignore: deprecated_member_use
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    this.songs.add(MusicalSong(
                      fileName: this.valueText,
                      pdfPath: "",
                      arranger: "",
                      genre: ""
                      )
                    );
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _deleteWarning(MusicalSong song) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              (LiveMusician.currentLanguage == Languages.ENGLISH) 
                ? 'Song will be deleted. Are you sure?'
                : 'Se eliminará la canción. Estás seguro?'
              
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text(
                  (LiveMusician.currentLanguage == Languages.ENGLISH) ? 'CANCEL' : 'CANCELAR'
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    this.songs.removeWhere((element) => song.fileName == element.fileName);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void reorderData(int oldindex, int newindex) async {
    setState(() {
      this.index = 1;
      if (newindex > oldindex) {
        newindex -= 1;
      }
      MusicalSong song = this.songs.removeAt(oldindex);
      this.songs.insert(newindex, song);
    });
  }

  void sortByName() {
    setState(() {
      //! Implement comparable or sorting algorithm
      this.songs.sort();
    });
  }

  Future<List<MusicalSong>> load() async {
    SharedPreferences listOrder = await SharedPreferences.getInstance();
    // await this.save();
    
    // ! Later, comment this one
    if (!_firstSave) {
      await this.save();
    } else {
      _firstSave = false;
    }
    
    List<MusicalSong> mySongs = [];

    for (int i = 0; i < listOrder.getInt("songNumber")!; i++ ) {

      List<String> musicalSongAttr = listOrder.getStringList('song$i')!;

      MusicalSong newSongToList = MusicalSong(
        fileName: musicalSongAttr[0], 
        pdfPath: musicalSongAttr[1],
        arranger: musicalSongAttr[2], 
        genre: musicalSongAttr[3]);

        mySongs.add(newSongToList);
        print("SONG cuando se CARGA: ${newSongToList.fileName}");
    }
    return mySongs;
  }

  Future<void> save() async {
    SharedPreferences data = await SharedPreferences.getInstance();

    int songNumber = 0;

    for (MusicalSong song in this.songs) {

      List<String> newSongToSave = [];
      newSongToSave.add(song.fileName!);
      newSongToSave.add(song.pdfPath!);
      newSongToSave.add(song.arranger!);
      newSongToSave.add(song.genre!);
      
      await data.setStringList('song$songNumber', newSongToSave);
      songNumber++;
      print("Canción NÚMERO $songNumber: $newSongToSave");
    }

    await data.setInt("songNumber", songNumber);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MusicalSong>>(
        future: Future.any([this.load()]),
        builder: (
          context,
          AsyncSnapshot<List<MusicalSong>> snapshot,
        ) {
          // Check hasData once for all futures.
          print("SNAPSHOT DATA: ${snapshot.data}");
          if (snapshot.hasData ) {
            // ************************************
              // Use the attr `this.songs` to perma-track all listed songs when the app it's running, 'cause another methods have to access the current availiable songs
              // in order to add a new one, delete, order them...
            this.songs = snapshot.data!;
            // ************************************
            this.index = 1;
            return Scaffold(
                backgroundColor: Colors.grey[800],
                appBar: AppBar(
                  backgroundColor: Colors.amber,
                  automaticallyImplyLeading: false,
                  title: Text(
                    "Partituras",
                    style: TextStyle(color: Colors.black87),
                  ),
                  centerTitle: true,
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.sort_by_alpha),
                        tooltip: "Orden alfabético",
                        onPressed: sortByName),
                  ],
                ),
                body: ReorderableListView(
                  children: <Widget> [
                    for (MusicalSong song in this.songs)
                      TextButton(
                        key: ValueKey(this.index),
                        child: Card(
                          color: Colors.black12,
                          key: ValueKey(this.index),
                          elevation: 15,
                          child: ListTile(
                            title: Text(
                              '${this.index++}.  ${song.fileName}',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                                (song.arranger!.isNotEmpty) ?
                                  '- Arreglista: ${song.arranger}\n' + 
                                  '- Género: ${song.genre}':   
                                  '- Arreglista: N/A\n' + 
                                  '- Género: N/A',
                                style: TextStyle(color: Colors.white),
                              ),
                            leading: (song.pdfPath!.isNotEmpty)
                              ? Icon(Icons.picture_as_pdf, color: Colors.white)
                              : Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                ),
                            trailing: TextButton(
                              child: Icon(
                                Icons.delete_forever_sharp,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _deleteWarning(song);
                                });
                              },
                            ),
                          ), 
                        ),
                        onPressed: () {
                          if (song.pdfPath!.isNotEmpty) {
                            print('song.PDF_PATH: ${song.pdfPath}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFReader(path: song.pdfPath, title: song.fileName,),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No hay partitura en PDF disponible.'),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                  onReorder: reorderData,
                ),
                floatingActionButton: SpeedDial(
                  backgroundColor: Colors.amber,
                  animatedIcon: AnimatedIcons.menu_close,
                  curve: Curves.bounceIn,
                  overlayColor: Colors.amber,
                  overlayOpacity: 0.5,
                  children: [
                    SpeedDialChild(
                        child: Icon(Icons.my_library_add_sharp),
                        backgroundColor: Colors.amber,
                        onTap: () {
                          addMusicalSongAsText(
                              getAddSongOnSpeedDial()[0],
                              getAddSongOnSpeedDial()[1]);
                        }
                      ),
                    SpeedDialChild(
                        child: Icon(Icons.picture_as_pdf_rounded),
                        backgroundColor: Colors.amber,
                        onTap: () {
                          setState(() {
                            _openFileExplorer(
                              allowMultiple: true,
                              pickingType: FileType.custom,
                              extension: ['pdf']
                            );
                          });
                        }
                      ),
                  ],
                )
              ); 
          } else {
            print("Still loading");
            return CircularProgressIndicator();
          }
        }
      );
  }
}


