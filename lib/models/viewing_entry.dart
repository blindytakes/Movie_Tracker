class ViewingEntry {
  final String id;
  final String title;
  final String type; // 'movie' or 'tv'
  final DateTime dateWatched;
  final int? rating; // 1-5 stars, nullable
  final String? notes;
  final String? posterUrl;
  final int? tmdbId;

  ViewingEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.dateWatched,
    this.rating,
    this.notes,
    this.posterUrl,
    this.tmdbId,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'dateWatched': dateWatched.toIso8601String(),
      'rating': rating,
      'notes': notes,
      'posterUrl': posterUrl,
      'tmdbId': tmdbId,
    };
  }

  // Create from Firestore map
  factory ViewingEntry.fromMap(Map<String, dynamic> map) {
    return ViewingEntry(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      dateWatched: DateTime.parse(map['dateWatched']),
      rating: map['rating'],
      notes: map['notes'],
      posterUrl: map['posterUrl'],
      tmdbId: map['tmdbId'],
    );
  }

  ViewingEntry copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? dateWatched,
    int? rating,
    String? notes,
    String? posterUrl,
    int? tmdbId,
  }) {
    return ViewingEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateWatched: dateWatched ?? this.dateWatched,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      posterUrl: posterUrl ?? this.posterUrl,
      tmdbId: tmdbId ?? this.tmdbId,
    );
  }
}