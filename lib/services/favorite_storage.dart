import 'package:shared_preferences/shared_preferences.dart';
import '../models/amiibo.dart';

class FavoriteStorage {
  static const String _key = 'favorite_amiibos';

  static Future<List<Amiibo>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((str) => Amiibo.fromJsonString(str)).toList();
  }

  static Future<Set<String>> getFavoriteIds() async {
    final favorites = await getFavorites();
    return favorites.map((a) => a.id).toSet();
  }

  static Future<void> _saveFavorites(List<Amiibo> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final list = favorites.map((a) => a.toJsonString()).toList();
    await prefs.setStringList(_key, list);
  }

  static Future<void> toggleFavorite(Amiibo amiibo) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((a) => a.id == amiibo.id);

    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(amiibo);
    }

    await _saveFavorites(favorites);
  }

  static Future<bool> isFavorite(Amiibo amiibo) async {
    final ids = await getFavoriteIds();
    return ids.contains(amiibo.id);
  }

  static Future<void> removeFavoriteById(String id) async {
    final favorites = await getFavorites();
    favorites.removeWhere((a) => a.id == id);
    await _saveFavorites(favorites);
  }
}
