import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:live_musician/all_songs_list_view.dart';
import 'package:live_musician/main.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class SetLists extends StatefulWidget {
  const SetLists({ Key? key }) : super(key: key);

  @override
  _SetListsState createState() => _SetListsState();
}

class _SetListsState extends State<SetLists> {

  bool _firstSave = true;
  List<String> setLists = [];
  int orderCounter = 0;

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
      (this.orderCounter % 2 == 0) ? 
        this.setLists.sort() : this.setLists.sort((b, a) => a.compareTo(b));
        this.orderCounter++;
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

    if (!_firstSave) {
      await this.save();
    } else {
      _firstSave = false;
    }

    if (data.getStringList('setLists') != null) {
      return data.getStringList('setLists')!;
    } else {
      return [];
    }
  }

  Future<void> save() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    await data.setStringList('setLists', this.setLists);
  }

  @override
  Widget build(BuildContext context) {
    int index = 1;
    return WillPopScope(
      onWillPop: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(title: LiveMusician.appBarTitle)
          )); 
        return Future.value(false);
      },
      child: FutureBuilder<List<String>>(
        future: Future.any([this.load()]),
        builder: (
          context,
          AsyncSnapshot<List<String>> snapshot,
          ) {
            // Check hasData once for all futures.
            print("SNAPSHOT DATA SETLISTS: ${snapshot.data}");
            if (snapshot.hasData) {
                this.getSnapshotData(snapshot);
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
                              /// Not implemented. Need to make `Setlist`a custom type first
                              // subtitle: Text("setlist: $setList"),
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
                                   LiveMusicianListView(
                                     setlist: setList,
                                     fromHome: false,
                                     )
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
              return CircularProgressIndicator();
            }
          }
        ),
    );
  }
}