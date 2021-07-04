import 'package:flutter/material.dart';
import 'package:live_musician/main.dart';

import '../musical_song.dart';

List<String> getAddSongOnSpeedDial() {
  if (LiveMusician.currentLanguage == Languages.ENGLISH) {
    return ['Add a new song to the list', 'Song or arrangement', 'Author or arranger', 'Genre'];
  } else {
    return ['Añade una nueva canción a la lista', 'Canción o arreglo', 'Autor o arreglista', 'Género'];
  }
}

String getCardSubtitle(MusicalSong song) {
  if (LiveMusician.currentLanguage == Languages.ENGLISH) {
    return (song.author!.isNotEmpty) ?
      '- Author: ${song.author}\n' + 
      '- Genre: ${song.genre}':   
      '- Author: N/A\n' + 
      '- Genre: N/A';
  } else {
    return (song.author!.isNotEmpty || song.genre!.isNotEmpty) ?
      '- Autor: ${song.author}\n' + 
      '- Género: ${song.genre}':   
      '- Autor: N/A\n' + 
      '- Género: N/A';
  }
}

Widget getLibraryDescription() {
  return (LiveMusician.currentLanguage == Languages.ENGLISH)
    ?  Column(
        children: [
          Text('List with all songs and music sheets'),
          Text('that you already upload to the library'),
          Text('_____________________'),
        ],
      )
    :  Column(
        children: [
          Text('Lista con todas las canciones y partituras'),
          Text('que hayas añadido a la biblioteca'),
          Text('_____________________'),
        ],
      );
}

Widget getSetlistDescription() {
  return (LiveMusician.currentLanguage == Languages.ENGLISH)
    ?  Column(
        children: [
          Text('Create setlists to order the songs like you need'),
          Text('with the music sheets and songs of the library'),
          Text('_____________________'),
        ],
      )
    :  Column(
        children: [
          Text('Crea repertorios con las canciones y/o'),
          Text('partituras de la librería'),
          Text('_____________________'),
        ],
      );
}

Widget getSettingsDescription() {
  return (LiveMusician.currentLanguage == Languages.ENGLISH)
    ?  Column(
        children: [
          Text('\nSelect the language in which you want'),
          Text('to view the application'),
          Text('______________________'),
        ],
      )
    :  Column(
        children: [
          Text('Selecciona el idioma en el cual'),
          Text('quieres ver la aplicación'),
          Text('______________________'),
        ],
      );
}