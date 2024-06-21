class SavedData {
  int id;
  int color;
  SavedData(this.id, this.color);

  factory SavedData.fromJson(Map<String, Object?> jsonMap){
    return SavedData(jsonMap["id"] as int, jsonMap["color"] as int);
  }
  Map toJson() => { "id": id, "color": color};

  @override
  toString() => "id: $id \t color: $color";
}
