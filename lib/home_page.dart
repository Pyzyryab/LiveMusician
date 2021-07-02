import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/LiveMusicianListView');
                print("Lector de partituras caldfsfled");
              }, 
              child: Text(
              'Lector de Partituras',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/PruebaPDF');
                print("Lector de PDF's");
              }, 
              child: Text(
                "Lector de PDF's",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/FileReader');
                print("FileReader");
              }, 
              child: Text(
                "FILE READER",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
