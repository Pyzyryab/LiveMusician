import 'package:live_musician/main.dart';

List<String> getAddSongOnSpeedDial() {
  if (LiveMusician.currentLanguage == Languages.ENGLISH) {
    return ['Add a new song to the list', 'Song or arrangement'];
  } else {
    return ['Añade una nueva canción a la lista', 'Canción o arreglo'];
  }
}