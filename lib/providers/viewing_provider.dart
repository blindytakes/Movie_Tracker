cat > lib/providers/viewing_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/viewing_entry.dart';
import '../services/database_service.dart';

class ViewingProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  List<ViewingEntry> _viewingEntries = [];
  List<ViewingEntry> get viewingEntries => _viewingEntries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void initialize() {
    _listenToViewingEntries();
  }

  void _listenToViewingEntries() {
    _databaseService.getViewingEntries().listen(
      (entries) {
        _viewingEntries = entries;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addViewingEntry({
    required String title,
    required String type,
    required DateTime dateWatched,
    int? rating,
    String? notes,
    String? posterUrl,
    int? tmdbId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final entry = ViewingEntry(
        id: _uuid.v4(),
        title: title,
        type: type,
        dateWatched: dateWatched,
        rating: rating,
        notes: notes,
        posterUrl: posterUrl,
        tmdbId: tmdbId,
      );

      await _databaseService.addViewingEntry(entry);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateViewingEntry(ViewingEntry entry) async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.updateViewingEntry(entry);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteViewingEntry(String entryId) async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.deleteViewingEntry(entryId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  List<ViewingEntry> getEntriesByType(String type) {
    return _viewingEntries.where((entry) => entry.type == type).toList();
  }

  List<ViewingEntry> get movies => getEntriesByType('movie');
  List<ViewingEntry> get tvShows => getEntriesByType('tv');

  Map<String, dynamic> getStatistics() {
    final totalEntries = _viewingEntries.length;
    final totalMovies = movies.length;
    final totalTvShows = tvShows.length;
    
    final ratedEntries = _viewingEntries.where((entry) => entry.rating != null);
    final averageRating = ratedEntries.isNotEmpty
        ? ratedEntries.map((entry) => entry.rating!).reduce((a, b) => a + b) / ratedEntries.length
        : 0.0;

    return {
      'totalEntries': totalEntries,
      'totalMovies': totalMovies,
      'totalTvShows': totalTvShows,
      'averageRating': averageRating,
    };
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _databaseService.signOut();
      _viewingEntries.clear();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
EOF