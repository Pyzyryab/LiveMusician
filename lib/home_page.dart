import 'package:flutter/material.dart';

import 'all_songs_list_view.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber,
        title: Center(child: Text(widget.title)),
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
                'Todas las canciones y partituras',
                style: TextStyle(
                  fontSize: 23
                ),
              ),
            ),
            SizedBox(
              child: Text('__________________________________'),
              height: 150,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/SetLists');
              }, 
              child: Text(
                "Setlists y canciones",
                style: TextStyle(
                  fontSize: 23
                ),
              ),
            ),
            SizedBox(
              child: Text('_____________________'),
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
