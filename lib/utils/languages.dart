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
    return (song.author!.isNotEmpty) ?
      '- Autor: ${song.author}\n' + 
      '- Género: ${song.genre}':   
      '- Autor: N/A\n' + 
      '- Género: N/A';
  }
}