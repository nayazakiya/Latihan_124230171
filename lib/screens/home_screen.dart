import 'package:flutter/material.dart';
import '../models/amiibo.dart';
import '../services/amiibo_api_service.dart';
import '../services/favorite_storage.dart';
import '../widgets/amiibo_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AmiiboApiService _apiService = AmiiboApiService();
  late Future<List<Amiibo>> _futureAmiibos;
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _futureAmiibos = _apiService.fetchAllAmiibos();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    final ids = await FavoriteStorage.getFavoriteIds();
    setState(() {
      _favoriteIds = ids;
    });
  }

  Future<void> _toggleFavorite(Amiibo amiibo) async {
    await FavoriteStorage.toggleFavorite(amiibo);
    await _loadFavoriteIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nintendo Amiibo List'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Amiibo>>(
        future: _futureAmiibos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureAmiibos = _apiService.fetchAllAmiibos();
              });
              await _loadFavoriteIds();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final amiibo = data[index];
                final isFav = _favoriteIds.contains(amiibo.id);
                return AmiiboCard(
                  amiibo: amiibo,
                  isFavorite: isFav,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(
                          amiibo: amiibo,
                        ),
                      ),
                    ).then((_) => _loadFavoriteIds());
                  },
                  onToggleFavorite: () => _toggleFavorite(amiibo),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
