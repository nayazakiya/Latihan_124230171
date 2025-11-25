import 'package:flutter/material.dart';
import '../models/amiibo.dart';
import '../services/favorite_storage.dart';

class DetailScreen extends StatefulWidget {
  final Amiibo amiibo;

  const DetailScreen({super.key, required this.amiibo});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final isFav = await FavoriteStorage.isFavorite(widget.amiibo);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    await FavoriteStorage.toggleFavorite(widget.amiibo);
    await _loadFavorite();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Release date dengan nama negara full + align kanan
  List<Widget> _buildReleaseInfo() {
    final release = widget.amiibo.release ?? {};

    // map key API -> nama negara
    const labelMap = {
      'au': 'Australia',
      'eu': 'Europe',
      'jp': 'Japan',
      'na': 'North America',
    };

    // urutan tampil
    const order = ['au', 'eu', 'jp', 'na'];

    final rows = <Widget>[];

    for (final key in order) {
      final date = release[key];
      if (date == null || date.isEmpty) continue;

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  labelMap[key] ?? key,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    date,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (rows.isEmpty) {
      return [const Text('No release date info')];
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final amiibo = widget.amiibo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amiibo Details'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar besar di atas
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  amiibo.image,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nama besar
            Text(
              amiibo.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Card info detail
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('Amiibo Series', amiibo.amiiboSeries),
                    _infoRow('Character', amiibo.character),
                    _infoRow('Game Series', amiibo.gameSeries),
                    _infoRow('Type', amiibo.type),
                    _infoRow('Head', amiibo.head),
                    _infoRow('Tail', amiibo.tail),
                    const SizedBox(height: 12),
                    const Divider(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Release Dates',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._buildReleaseInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Row label kiri, value kanan (seperti di desain)
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
