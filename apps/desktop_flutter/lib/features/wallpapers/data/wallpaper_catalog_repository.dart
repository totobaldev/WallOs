import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/wallpaper_item.dart';

class WallpaperCatalogRepository {
  const WallpaperCatalogRepository();

  Future<List<WallpaperItem>> loadCatalog() async {
    try {
      final jsonString = await rootBundle.loadString('assets/catalog/wallpapers.json');
      final decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return const [];
      }

      final items = decoded['items'];
      if (items is! List) {
        return const [];
      }

      return items
          .whereType<Map>()
          .map((rawItem) => WallpaperItem.fromJson(Map<String, dynamic>.from(rawItem)))
          .where((item) => item.id.isNotEmpty && item.previewAssetPath.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}
