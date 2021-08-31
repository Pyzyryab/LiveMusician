import 'package:live_musician/home_page.dart';
import 'package:live_musician/main.dart';
import 'package:live_musician/musical_song.dart';
import 'package:live_musician/select_from_all_songs.dart';
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

  String? setlist = '';
  bool? fromHome;

  LiveMusicianListView({String? setlist, bool? fromHome, Key? key}) : super(key: key) {
    this.setlist = setlist;
    this.fromHome = fromHome;
  }

  @override
  _LiveMusicianListViewState createState() => _LiveMusicianListViewState();
}

class _LiveMusicianListViewState extends State<LiveMusicianListView> {
  
  bool _firstSave = true;
  List<MusicalSong> songs = [];
  String currentSetList = '';
  bool fromHome = false;
  bool listOrderController = false;
  int orderCounter = 0;

  @override
  void initState() {
    super.initState();
    currentSetList = (widget.setlist == null) ? 'ALL' : widget.setlist!;
    fromHome = widget.fromHome!;
  }

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
          this.addSongWithPDFIfNotExists(element, doc);
        });
      }
  }

  /// Method that appends a new `MusicalSong` to the `this.songs` attribute if that MusicalSong isn't on the list yet.
  void addSongWithPDFIfNotExists(PlatformFile element, PDFDoc doc) {
    String formattedPDFName = element.name.replaceAll(RegExp(r'.pdf'), '').trim().capitalizeFirstofEach;
    bool alreadyOnList = false;

    for (MusicalSong musicalSong in this.songs) {
      if (musicalSong.fileName == formattedPDFName) {
        alreadyOnList = true;
        break;
      }
    }

    (alreadyOnList)
      ? ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (LiveMusician.currentLanguage == Languages.ENGLISH)
                ? 'The PDF it\'s already on list, or another one has the same name.'
                : 'El PDF ya está en la lista, o existe uno con el mismo nombre.',
                ),
            ),
          )
      : this.songs.add(
          MusicalSong(
          fileName: element.name.replaceAll(RegExp(r'.pdf'), '').trim().capitalizeFirstofEach, 
          pdfPath: element.path!, 
          author: (doc.info.author != "" && doc.info.author != null) ? doc.info.author! : "Sin datos",
          genre: (doc.info.keywords != [] && doc.info.keywords != null) ? doc.info.keywords![0].capitalize : "...",
        )
      );
  }
              

  final _songNameFieldController = TextEditingController();
  final _songAuthorFieldController = TextEditingController();
  final _songGenreFieldController = TextEditingController();

  void clearTextFields() {
    _songNameFieldController.clear();
    _songAuthorFieldController.clear();
    _songGenreFieldController.clear();
  }

  Future<void> addMusicalSongAsText(String title, String songPlaceholder, 
    String authorPlaceholder, String genrePlaceholder) async {
      
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            height: 200,
            child: Column(
              children: <Widget> [ 
                Expanded(
                  child: TextField(
                    controller: _songNameFieldController,
                    decoration: InputDecoration(hintText: songPlaceholder),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _songAuthorFieldController,
                    decoration: InputDecoration(hintText: authorPlaceholder),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _songGenreFieldController,
                    decoration: InputDecoration(hintText: genrePlaceholder),
                  ),
                ),
              ]
            ),
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
                  clearTextFields();
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
                  bool alreadyOnList = false;
                  
                  for (MusicalSong musicalSong in this.songs) {
                    if (musicalSong.fileName == _songNameFieldController.text 
                      && musicalSong.author == _songAuthorFieldController.text
                      && musicalSong.genre == _songGenreFieldController.text
                    ) {
                      alreadyOnList = true;
                      break;
                    }
                  }

                  (alreadyOnList)
                    ? ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              (LiveMusician.currentLanguage == Languages.ENGLISH)
                              ? 'The song it\'s already on list, or another one has the same name.'
                              : 'La canción ya está en la lista, o existe uno con el mismo nombre.',
                              ),
                          ),
                        )
                    :  this.songs.add(MusicalSong(
                        fileName: _songNameFieldController.text,
                        pdfPath: "", // No "by hand" paths allowed
                        author: _songAuthorFieldController.text,
                        genre: _songGenreFieldController.text,
                        )
                      );
                      clearTextFields();
                      Navigator.pop(context); 
                });
              },
            ),
          ],
        );
      }
    );
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
      if (newindex > oldindex) {
        newindex -= 1;
      }
      MusicalSong song = this.songs.removeAt(oldindex);
      this.songs.insert(newindex, song);
    });
  }

  void sortByName() {
    setState(() {
      (this.orderCounter % 2 == 0) ? 
        this.songs.sort() : this.songs.sort((b, a) => a.fileName!.compareTo(b.fileName!));
    });
  }

  void getSnapshotData(AsyncSnapshot<List<MusicalSong>> snapshot) {
    this.songs = snapshot.data!;
    snapshot.data!.forEach((element) {  });
  }

  Future<List<MusicalSong>> load() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    
    List<MusicalSong> mySongs = [];

    if (!_firstSave) {
      await this.save();
    } else {
      _firstSave = false;
    }

    if (data.getStringList('song0${this.currentSetList}') != null
      && data.getInt("songNumber${this.currentSetList}") != null) {

      for (int i = 0; i < data.getInt("songNumber${this.currentSetList}")!; i++ ) {

        List<String> musicalSongAttr = data.getStringList('song$i$currentSetList')!;

        MusicalSong newSongToList = MusicalSong(
          fileName: musicalSongAttr[0], 
          pdfPath: musicalSongAttr[1],
          author: musicalSongAttr[2], 
          genre: musicalSongAttr[3]);

          mySongs.add(newSongToList);
      }
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
      newSongToSave.add(song.author!);
      newSongToSave.add(song.genre!);
      
      await data.setStringList('song$songNumber$currentSetList', newSongToSave);
      songNumber++;
    }

    await data.setInt("songNumber${this.currentSetList}", songNumber);
  }

  @override
  Widget build(BuildContext context) {

    int index = 0;

    return WillPopScope(
      onWillPop: () {
        if (this.fromHome) {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(title: LiveMusician.appBarTitle)
          )); 
        } else {
          Navigator.popAndPushNamed(context, '/SetLists');
        }

        return Future.value(false);
      },
      child: FutureBuilder<List<MusicalSong>>(
          future: Future.any([this.load()]),
          builder: (
            context,
            AsyncSnapshot<List<MusicalSong>> snapshot,
          ) {
            // Check hasData once for all futures.
            if (snapshot.hasData) {
              // ************************************
                // Use the attr `this.songs` to perma-track all listed songs when the app it's running, 'cause another methods have to access the current availiable songs
                // in order to add a new one, delete, order them...
                this.getSnapshotData(snapshot);
              // ************************************
              index = 1;
              return Scaffold(
                  backgroundColor: Colors.grey[800],
                  appBar: AppBar(
                    backgroundColor: Colors.amber,
                    automaticallyImplyLeading: false,
                    title: Text(
                      (!fromHome) ? currentSetList
                        : (LiveMusician.currentLanguage == Languages.ENGLISH) 
                          ? 'Library' : 'Librería',
                      style: TextStyle(color: Colors.black87),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(Icons.sort_by_alpha),
                          tooltip: (LiveMusician.currentLanguage == Languages.ENGLISH) 
                            ? "Alphabetical order" : "Orden alfabético",
                          onPressed: sortByName),
                    ],
                  ),
                  body: ReorderableListView(
                    children: <Widget> [
                      for (MusicalSong song in snapshot.data!)
                        TextButton(
                          key: ValueKey(index),
                          child: Card(
                            color: Colors.black12,
                            key: ValueKey(index),
                            elevation: 15,
                            child: ListTile(
                              title: Text(
                                '${index++}.  ${song.fileName}',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                  getCardSubtitle(song),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFReader(
                                    path: song.pdfPath, 
                                    title: song.fileName,
                                    song: song
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    (LiveMusician.currentLanguage == Languages.ENGLISH)
                                    ? 'No music sheet availiable'
                                    : 'No hay partitura en PDF disponible.',
                                    ),
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
                    overlayColor: Colors.transparent,
                    overlayOpacity: 0.5,
                    activeForegroundColor: Colors.green,
                    children: (!fromHome) ? [
                      SpeedDialChild(
                          child: Icon(Icons.list),
                          backgroundColor: Colors.amber,
                          label: (LiveMusician.currentLanguage == Languages.ENGLISH)
                            ? 'Add a new song and his data\n(name, autor and genre) to the library'
                            : 'Añade una nueva canción y su\ninformación a la librería',
                          labelBackgroundColor: Colors.white54,
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => 
                                    SelectFromAllSongs(
                                      setList: this.currentSetList,
                                    )
                                )
                              );
                            });
                          }
                        ),
                      ]
                      : [
                      SpeedDialChild(
                          child: Icon(Icons.picture_as_pdf_rounded),
                          backgroundColor: Colors.amber,
                          label: (LiveMusician.currentLanguage == Languages.ENGLISH)
                            ? 'Add a new music sheet or\ndocument as PDF to the library'
                            : 'Añade un nuevo PDF como partitura\no como documento a la librería',
                          labelBackgroundColor: Colors.white54,
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
                      SpeedDialChild(
                          child: Icon(Icons.my_library_add_sharp),
                          backgroundColor: Colors.amber,
                          label: (LiveMusician.currentLanguage == Languages.ENGLISH)
                            ? 'Load songs from the library'
                            : 'Añade canciones desde la librería',
                          labelBackgroundColor: Colors.white54,
                          onTap: () {
                            List<String> byHandAddedSong = getAddSongOnSpeedDial();
                            addMusicalSongAsText(
                                byHandAddedSong[0],
                                byHandAddedSong[1],
                                byHandAddedSong[2],
                                byHandAddedSong[3],
                              );
                          }
                        ),
                    ],
                  )
                ); 
            } else {
              return CircularProgressIndicator();
            }
          }
        ),
    );
  }
}