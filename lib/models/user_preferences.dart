/// Data model representing user preferences for the app.
///
/// Currently stores the selected genre filter preference.
/// A [selectedGenre] value of null means "All" genres (no filter applied).
class UserPreferences {
  final String? selectedGenre;

  const UserPreferences({this.selectedGenre});

  /// Creates a [UserPreferences] instance from a JSON map.
  ///
  /// Expects optional key: 'selectedGenre'.
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      selectedGenre: json['selectedGenre'] as String?,
    );
  }

  /// Converts this [UserPreferences] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'selectedGenre': selectedGenre,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences && other.selectedGenre == selectedGenre;
  }

  @override
  int get hashCode => selectedGenre.hashCode;

  @override
  String toString() => 'UserPreferences(selectedGenre: $selectedGenre)';
}
