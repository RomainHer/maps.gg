class VideoGame {
  int id;
  String displayName;
  String name;

  VideoGame({
    required this.id,
    required this.displayName,
    required this.name,
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
