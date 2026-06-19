import 'package:flutter/material.dart';

import '../domain/wallpaper_item.dart';
import 'wallos_controller.dart';

class WallpaperGrid extends StatelessWidget {
  const WallpaperGrid({
    super.key,
    required this.items,
    required this.controller,
    required this.onSelect,
  });

  final List<WallpaperItem> items;
  final WallOsController controller;
  final ValueChanged<WallpaperItem> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1280
            ? 4
            : constraints.maxWidth >= 900
                ? 3
                : 2;

        return GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final wallpaper = items[index];
            final isFavorite = controller.isFavorite(wallpaper.id);

            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onSelect(wallpaper),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              wallpaper.previewAssetPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return ColoredBox(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                                );
                              },
                            ),
                          ),
                          if (controller.watermarkVisible)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.38),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Text(
                                    WallOsController.watermarkHintText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                iconSize: 20,
                                onPressed: () => controller.toggleFavorite(wallpaper.id),
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                tooltip: isFavorite
                                    ? 'Quitar de favoritos'
                                    : 'Agregar a favoritos',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Text(
                        wallpaper.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
