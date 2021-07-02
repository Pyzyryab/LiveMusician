import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'all_songs_list_view.dart';
import 'main.dart';
import 'musical_song.dart';


class SelectFromAllSongs extends StatefulWidget {

  String? setList = '';

  SelectFromAllSongs({String? setList}) {
    this.setList = setList;
  }

  @override
  _SelectFromAllSongsState createState() => _SelectFromAllSongsState();
}

class _SelectFromAllSongsState extends State<SelectFromAllSongs> {
  
  List<MusicalSong> staticData = [];
  List<MusicalSong> songsToSave = [];
  Map<int, bool> selectedFlag = {};
  String currentSetList = '';

  @override
  void initState() {
    super.initState();
    this.unwrapFromFuture();
    this.currentSetList = widget.setList!;
  }

  void unwrapFromFuture() async {
    songsToSave = await this.loadSpecificSetList();
    staticData = await this.load();
  }

  Future<List<MusicalSong>> load() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    
    List<MusicalSong> mySongs = [];

    if (data.getStringList('song0ALL') != null
      && data.getInt("songNumberALL") != null) {

      for (int i = 0; i < data.getInt("songNumberALL")!; i++ ) {

        List<String> musicalSongAttr = data.getStringList('song${i}ALL')!;

        MusicalSong newSongToList = MusicalSong(
          fileName: musicalSongAttr[0], 
          pdfPath: musicalSongAttr[1],
          arranger: musicalSongAttr[2], 
          genre: musicalSongAttr[3]);

          mySongs.add(newSongToList);
      }
    }
    return mySongs;
  }

  Future<List<MusicalSong>> loadSpecificSetList() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    
    List<MusicalSong> mySongs = [];

    if (data.getStringList('song0${this.currentSetList}') != null
      && data.getInt("songNumber${this.currentSetList}") != null) {

      for (int i = 0; i < data.getInt("songNumber${this.currentSetList}")!; i++ ) {

        List<String> musicalSongAttr = data.getStringList('song$i${this.currentSetList}')!;

        MusicalSong newSongToList = MusicalSong(
          fileName: musicalSongAttr[0], 
          pdfPath: musicalSongAttr[1],
          arranger: musicalSongAttr[2], 
          genre: musicalSongAttr[3]);

          mySongs.add(newSongToList);
      }
    }
    return mySongs;
  }

  Future<void> save() async {
    SharedPreferences data = await SharedPreferences.getInstance();

    int songNumber = 0;

    for (MusicalSong song in this.songsToSave) {

      List<String> newSongToSave = [];
      newSongToSave.add(song.fileName!);
      newSongToSave.add(song.pdfPath!);
      newSongToSave.add(song.arranger!);
      newSongToSave.add(song.genre!);
      
      await data.setStringList('song$songNumber$currentSetList', newSongToSave);
      songNumber++;
      print("Canción NÚMERO $songNumber: $newSongToSave");
    }

    await data.setInt("songNumber${this.currentSetList}", songNumber);
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Backbutton pressed (device or appbar button), do whatever you want.');

        //trigger leaving and use own data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveMusicianListView(setlist: this.currentSetList)
          )
        );

        //we need to return a future
        return Future.value(false);
      },
      child: 
      FutureBuilder<List<MusicalSong>>(
          future: Future.any([this.load()]),
          builder: (
            context,
            AsyncSnapshot<List<MusicalSong>> snapshot,
          ) {
            if (snapshot.hasData) {
              return Scaffold(
                  backgroundColor: Colors.grey[800],
                  appBar: AppBar(
                    backgroundColor: Colors.amber,
                    automaticallyImplyLeading: false,
                    title: Text(
                      this.currentSetList,
                      style: TextStyle(color: Colors.black87),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(Icons.sort_by_alpha),
                          tooltip: (LiveMusician.currentLanguage == Languages.ENGLISH) 
                            ? "Alphabetical order"
                            : "Orden alfabético",
                          onPressed: null),
                    ],
                  ),
                  body: ListView.builder(
                    itemBuilder: (builder, index) {
                      MusicalSong song = staticData[index];
                      selectedFlag[index] = selectedFlag[index] ?? false;
                      bool isSelected = false;

                      for (var element in this.songsToSave) {
                        if (song.fileName == element.fileName) {
                          isSelected = !selectedFlag[index]!;
                        } 
                      }

                      return Card(
                        color: Colors.black12,
                        child: ListTile(
                          onTap: () => onTap(isSelected, index, snapshot.data!),
                          title: Text(
                            song.fileName!,
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
                          leading: _buildSelectIcon(isSelected, song),
                        ),
                      );
                  },
                  itemCount: staticData.length,
                ),
                floatingActionButton: _buildSelectAllButton(),
              );
            } else {
              return CircularProgressIndicator();
            }
          }
        ),
    );
  }

  void onTap(bool isSelected, int index, List<MusicalSong> snapshotData) {
    if (!isSelected) {
        setState(() {
          selectedFlag[index] = isSelected;
          this.songsToSave.add(snapshotData[index]);
      });
    } else {
        setState(() {
          selectedFlag[index] = !isSelected;
          this.songsToSave.removeWhere((element) => snapshotData[index].fileName == element.fileName);
      });
    }
    this.save();
  }


  Widget _buildSelectIcon(bool isSelected, MusicalSong song) {
    print("Song '${song.fileName}' isSelected status is: $isSelected");
    return Icon(
      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
      color: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSelectAllButton() {
    bool icon = (this.songsToSave.length != this.staticData.length) ? true : false;

    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _selectAll();
        });
      },
      child: Icon(
        icon ? Icons.done_all : Icons.remove_done,
      ),
    );
  }

  void _selectAll() {
    if (this.songsToSave.length == this.staticData.length) {
      setState(() {
        this.songsToSave.clear();
      });
    } else {
      setState(() {
        this.songsToSave.clear();
        this.songsToSave.addAll(this.staticData);
      });
    }

    this.save();
    _buildSelectAllButton();
  }

}