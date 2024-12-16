class VideoGame {
  int id;
  String displayName;
  String name;
  String imageUrl;
  double imageRatio;

  VideoGame({
    required this.id,
    required this.displayName,
    required this.name,
    required this.imageUrl,
    required this.imageRatio,
  });

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(other) {
    // Dart ensures that operator== isn't called with null
    // if(other == null) {
    //   return false;
    // }
    if (other is! VideoGame) {
      return false;
    }
    return id == other.id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
