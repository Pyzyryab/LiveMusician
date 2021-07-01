class MusicalSong {

  String? fileName;
  String? pdfPath;

  String? arranger;
  String? genre;

  MusicalSong({
    required String fileName, 
    required String pdfPath, 
    required String arranger,
    required String genre,
    }) {
    this.fileName = fileName;
    this.pdfPath = pdfPath;
    this.arranger = arranger;
    this.genre = genre;
  }

}