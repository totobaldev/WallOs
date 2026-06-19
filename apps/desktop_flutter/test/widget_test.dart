import 'package:flutter_test/flutter_test.dart';

import 'package:wallos_desktop/features/wallpapers/data/wallpaper_catalog_repository.dart';
import 'package:wallos_desktop/features/wallpapers/presentation/wallos_controller.dart';
import 'package:wallos_desktop/main.dart';

void main() {
  testWidgets('renders WallOs shell', (WidgetTester tester) async {
    final controller = WallOsController(repository: const WallpaperCatalogRepository());

    await tester.pumpWidget(WallOsApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('WallOs'), findsOneWidget);
    expect(find.text('Explore wallpapers'), findsOneWidget);
  });
}
