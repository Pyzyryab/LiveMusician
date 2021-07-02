class MusicalSong implements Comparable<MusicalSong> {

  String? fileName;
  String? pdfPath;

  String? arranger;
  String? genre;

  // Empty named constructor for whe Futures need to validate non-null data
  MusicalSong.emptySong();

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

  @override
  int compareTo(MusicalSong other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

}