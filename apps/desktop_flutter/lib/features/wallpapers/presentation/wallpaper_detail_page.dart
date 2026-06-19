import 'package:flutter/material.dart';

import '../domain/wallpaper_item.dart';
import 'wallos_controller.dart';

class WallpaperDetailPage extends StatelessWidget {
  const WallpaperDetailPage({
    super.key,
    required this.wallpaper,
    required this.controller,
    required this.onSupportCreator,
  });

  final WallpaperItem wallpaper;
  final WallOsController controller;
  final VoidCallback onSupportCreator;

  @override
  Widget build(BuildContext context) {
    final isFavorite = controller.isFavorite(wallpaper.id);

    return Scaffold(
      appBar: AppBar(title: Text(wallpaper.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            wallpaper.previewAssetPath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return ColoredBox(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                              );
                            },
                          ),
                        ),
                        if (controller.watermarkVisible)
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 18,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                WallOsController.watermarkHintText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.25,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(wallpaper.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  wallpaper.width > 0 && wallpaper.height > 0
                      ? 'Dimensiones: ${wallpaper.width} x ${wallpaper.height} px'
                      : 'Dimensiones: sin datos disponibles',
                ),
                const SizedBox(height: 4),
                Text('Subido por: ${wallpaper.uploadedBy}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wallpaper.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        final message = await controller.applyWallpaper(wallpaper);
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                      },
                      icon: const Icon(Icons.wallpaper_outlined),
                      label: const Text('Aplicar fondo'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => controller.toggleFavorite(wallpaper.id),
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      label: Text(isFavorite ? 'En favoritos' : 'Guardar favorito'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: onSupportCreator,
                      icon: const Icon(Icons.volunteer_activism_outlined),
                      label: const Text('Apoyar creador'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
