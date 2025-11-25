import 'package:flutter/material.dart';
import '../models/amiibo.dart';
import '../services/favorite_storage.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Amiibo>> _futureFavorites;

  @override
  void initState() {
    super.initState();
    _futureFavorites = FavoriteStorage.getFavorites();
  }

  Future<void> _reload() async {
    setState(() {
      _futureFavorites = FavoriteStorage.getFavorites();
    });
  }

  Future<void> _removeFavorite(Amiibo amiibo) async {
    await FavoriteStorage.removeFavoriteById(amiibo.id);
    await _reload();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${amiibo.name} removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Amiibo>>(
        future: _futureFavorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Text('No favorites yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final amiibo = favorites[index];

              return Dismissible(
                key: ValueKey(amiibo.id),
                direction: DismissDirection.horizontal, // bisa kiri & kanan
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _removeFavorite(amiibo);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          amiibo.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        amiibo.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(amiibo.head),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(amiibo: amiibo),
                          ),
                        ).then((_) => _reload());
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
