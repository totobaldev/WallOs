class WallpaperItem {
  const WallpaperItem({
    required this.id,
    required this.title,
    required this.previewAssetPath,
    required this.width,
    required this.height,
    required this.uploadedBy,
    required this.supportUrl,
    required this.tags,
  });

  final String id;
  final String title;
  final String previewAssetPath;
  final int width;
  final int height;
  final String uploadedBy;
  final String supportUrl;
  final List<String> tags;

  factory WallpaperItem.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final rawWidth = json['width'];
    final rawHeight = json['height'];

    return WallpaperItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled wallpaper',
      previewAssetPath: json['previewAssetPath'] as String? ?? '',
      width: rawWidth is int ? rawWidth : 0,
      height: rawHeight is int ? rawHeight : 0,
      uploadedBy: json['uploadedBy'] as String? ?? 'Comunidad WallOs',
      supportUrl: json['supportUrl'] as String? ?? 'https://buymeacoffee.com/wallos',
      tags: rawTags is List
          ? rawTags.whereType<String>().toList(growable: false)
          : const ['wallpaper'],
    );
  }
}
