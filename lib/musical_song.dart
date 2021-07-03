class MusicalSong implements Comparable<MusicalSong> {

  String? fileName;
  String? pdfPath;

  String? author;
  String? genre;

  // Empty named constructor for whe Futures need to validate non-null data
  MusicalSong.emptySong();

  MusicalSong({
    required String fileName, 
    required String pdfPath, 
    required String author,
    required String genre,
    }) {
    this.fileName = fileName;
    this.pdfPath = pdfPath;
    this.author = author;
    this.genre = genre;
  }

  @override
  int compareTo(MusicalSong other) {
    if (this.fileName?.compareTo(other.fileName!) == -1) {
      return -1;
    } else if (this.fileName?.compareTo(other.fileName!) == 1) {
      return 1;
    } else {
      return 0;
    }
  }

}