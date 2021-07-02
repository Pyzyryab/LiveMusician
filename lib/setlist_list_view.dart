import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:live_musician/all_songs_list_view.dart';
import 'package:live_musician/main.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetLists extends StatefulWidget {
  const SetLists({ Key? key }) : super(key: key);

  @override
  _SetListsState createState() => _SetListsState();
}

class _SetListsState extends State<SetLists> {

  bool _firstSave = true;
  List<String> setLists = [];

  void reorderData(int oldindex, int newindex) async {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      String setList = this.setLists.removeAt(oldindex);
      this.setLists.insert(newindex, setList);
    });
  }

  void sortByName() {
    setState(() {
      //! Implement comparable or sorting algorithm
      this.setLists.sort();
    });
  }

  void getSnapshotData(AsyncSnapshot<List<String>> snapshot) {
    this.setLists = snapshot.data!;
  }

  Future<void> addSetList() async {
    String valueText = "";
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            (LiveMusician.currentLanguage == Languages.ENGLISH) 
              ? 'Add a new setlist' : 'Añade un nuevo setlist'
          ),
          content: TextField(
            onChanged: (value) {
                valueText = value;
            },
            decoration: InputDecoration(
              hintText: (LiveMusician.currentLanguage == Languages.ENGLISH)
                ? 'Setlist name' : 'Nombre del setlist'
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
                  this.setLists.add(valueText);
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      });
  }

  Future<void> _deleteWarning(String setList) async {
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
                    this.setLists.remove(setList);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<List<String>> load() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    // await this.save();
    if (!_firstSave) {
      await this.save();
    } else {
      _firstSave = false;
    }

    return data.getStringList('setLists')!;
  }

  Future<void> save() async {
    SharedPreferences data = await SharedPreferences.getInstance();

    await data.setStringList('setLists', this.setLists);
  }

  @override
  Widget build(BuildContext context) {
    int index = 1;
    return FutureBuilder<List<String>>(
      future: Future.any([this.load()]),
      builder: (
        context,
        AsyncSnapshot<List<String>> snapshot,
        ) {
          // Check hasData once for all futures.
          print("SNAPSHOT DATA SETLISTS: ${snapshot.data}");
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
                    "SetLists",
                    style: TextStyle(color: Colors.black87),
                  ),
                  centerTitle: true,
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.sort_by_alpha),
                        tooltip: (LiveMusician.currentLanguage == Languages.ENGLISH) 
                          ? "Alphabetical order"
                          : "Orden alfabético",
                        onPressed: sortByName),
                  ],
                ),
                body: ReorderableListView(
                  children: <Widget> [
                    for (String setList in snapshot.data!)
                      TextButton(
                        key: ValueKey(index),
                        child: Card(
                          color: Colors.black12,
                          key: ValueKey(index),
                          elevation: 15,
                          child: ListTile(
                            title: Text(
                              '${index++}.  $setList',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text("setlist: $setList"),
                            leading: Icon(
                                  Icons.list,
                                  color: Colors.white,
                                ),
                            trailing: TextButton(
                              child: Icon(
                                Icons.delete_forever_sharp,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _deleteWarning(setList);
                                });
                              },
                            ),
                          ), 
                        ),
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => 
                                 LiveMusicianListView(setlist: setList)
                              ),
                            );
                          }
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
                          addSetList();
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