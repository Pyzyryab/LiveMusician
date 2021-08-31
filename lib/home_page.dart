import 'package:flutter/material.dart';
import 'package:live_musician/utils/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'all_songs_list_view.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> languageSelector() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              (LiveMusician.currentLanguage == Languages.ENGLISH) 
                ? 'Select your language'
                : 'Escoge tu idioma'
            ),
            content: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget> [
                  RaisedButton(
                    color: Colors.yellow,
                    onPressed: () {
                      LiveMusician.currentLanguage = Languages.ENGLISH;
                      Navigator.popAndPushNamed(
                        context, '/HomePage');
                        this.saveLanguagePreferences();
                    }, 
                    child: Text(
                      'English',
                      style: TextStyle(color: Colors.black87),
                    )
                  ),
                  RaisedButton(
                    color: Colors.yellow,
                    onPressed: () {
                      LiveMusician.currentLanguage = Languages.SPANISH;
                      Navigator.popAndPushNamed(
                        context, '/HomePage');
                        this.saveLanguagePreferences();
                    }, 
                    child: Text(
                      'Español',
                      style: TextStyle(color: Colors.black87),
                    )
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> loadLanguagePreferences() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    
    try {
      var language = data.getString('language');

      (language == 'Languages.ENGLISH') 
        ? LiveMusician.currentLanguage = Languages.ENGLISH
        : LiveMusician.currentLanguage = Languages.SPANISH;
    } catch (error) {
      LiveMusician.currentLanguage = Languages.ENGLISH;
    }

    print("Loaded language: ${LiveMusician.currentLanguage}");
  }

  Future<void> saveLanguagePreferences() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    await data.setString('language', LiveMusician.currentLanguage.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.wait([loadLanguagePreferences()]),
      builder: (
        context,
        AsyncSnapshot<void> snapshot
      ) {
        if (snapshot.hasData) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: Colors.grey[800],
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.amber,
                title: Center(child: Text(widget.title)),
                actions: [
                  // FloatingActionButton(
                  //   child: Icon(Icons.more_horiz),
                  //   onPressed: () {
                  //     menu();
                  //   }),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveMusicianListView(
                              setlist: 'ALL',
                              fromHome: true
                            )
                          )
                        );
                      }, 
                      child: Text(
                        (LiveMusician.currentLanguage == Languages.ENGLISH)
                          ? 'Music Library' : 'Librería de Música',
                        style: TextStyle(
                          fontSize: 23
                        ),
                      ),
                    ),
                    SizedBox(
                      child: getLibraryDescription(),
                      height: 100,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/SetLists');
                      }, 
                      child: Text(
                        (LiveMusician.currentLanguage == Languages.ENGLISH)
                          ? 'Setlists' : 'Setlists y canciones',
                        style: TextStyle(
                          fontSize: 23
                        ),
                      ),
                    ),
                    SizedBox(
                      child: getSetlistDescription(),
                      height: 150,
                    ),
                    Column(
                      children: [
                        Text('__________________________________________'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text( (LiveMusician.currentLanguage == Languages.ENGLISH)
                              ? '\nConfiguration zone' : '\nConfiguración',
                              style: TextStyle(
                                fontSize: 20
                                ),
                              ),
                              Icon(Icons.settings)
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            languageSelector();
                          }, 
                          child: Text(
                            (LiveMusician.currentLanguage == Languages.ENGLISH)
                              ? 'Languages' : 'Idiomas',
                            style: TextStyle(
                              fontSize: 23
                            ),
                          ),
                        ),
                        SizedBox(
                          child: getSettingsDescription(),
                          height: 150,
                        ),
                      ]
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }
}
