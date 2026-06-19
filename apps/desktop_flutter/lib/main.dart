import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'core/theme/wallos_theme.dart';
import 'features/settings/presentation/settings_view.dart';
import 'features/wallpapers/data/wallpaper_catalog_repository.dart';
import 'features/wallpapers/domain/wallpaper_item.dart';
import 'features/wallpapers/presentation/wallos_controller.dart';
import 'features/wallpapers/presentation/wallpaper_grid.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = WallOsController(repository: const WallpaperCatalogRepository());
  runApp(WallOsApp(controller: controller));
}

class WallOsApp extends StatefulWidget {
  const WallOsApp({super.key, required this.controller});

  final WallOsController controller;

  @override
  State<WallOsApp> createState() => _WallOsAppState();
}

class _WallOsAppState extends State<WallOsApp> {
  int _selectedIndex = 0;
  WallpaperItem? _selectedWallpaper;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'WallOs',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          scaffoldMessengerKey: _scaffoldMessengerKey,
          theme: buildWallOsTheme(),
          home: Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rightPanelWidth = constraints.maxWidth >= 1380 ? 320.0 : 280.0;

                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                        child: _NavigationPanel(
                          selectedIndex: _selectedIndex,
                          onSelect: (index) => setState(() => _selectedIndex = index),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.74),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.38),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Expanded(child: _buildSection(context)),
                                  if (widget.controller.watermarkVisible) ...[
                                    const SizedBox(height: 10),
                                    const _WatermarkFooterNotice(),
                                  ],
                                  const SizedBox(height: 10),
                                  const _AppFooter(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                        child: SizedBox(
                          width: rightPanelWidth,
                          child: _InspectorPanel(
                            controller: widget.controller,
                            selectedWallpaper: _selectedWallpaper,
                            onApplyWallpaper: _applySelectedWallpaper,
                            onRedeemCode: _promptReferralCode,
                            onCopyCode: _copyReferralCode,
                            onPurchaseUnlock: _purchaseUnlock,
                            onRemoveWatermark: _removeWatermark,
                            onSupportCreator: _supportCreator,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return _CatalogSection(
          title: 'Explore wallpapers',
          subtitle: 'Coleccion local sincronizada desde la carpeta fondos.',
          emptyMessage:
              'No hay wallpapers en el catalogo. Ejecuta npm run wallpapers:sync:flutter para sincronizar.',
          items: widget.controller.wallpapers,
          controller: widget.controller,
          isLoading: widget.controller.isLoading,
          onSelect: _handleWallpaperSelection,
        );
      case 1:
        return _CatalogSection(
          title: 'Favoritos',
          subtitle: 'Wallpapers guardados para acceso rapido.',
          emptyMessage: 'Todavia no tienes favoritos. Marca algunos desde Explore.',
          items: widget.controller.favorites,
          controller: widget.controller,
          isLoading: widget.controller.isLoading,
          onSelect: _handleWallpaperSelection,
        );
      case 2:
        return SettingsView(controller: widget.controller);
      case 3:
        return const _FaqSection();
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleWallpaperSelection(WallpaperItem item) {
    setState(() => _selectedWallpaper = item);
  }

  Future<void> _promptReferralCode() async {
    final textController = TextEditingController();
    final navigatorContext = _navigatorKey.currentContext;

    if (navigatorContext == null) {
      textController.dispose();
      return;
    }

    final referralCode = await showDialog<String>(
      context: navigatorContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Canjear codigo'),
          content: TextField(
            controller: textController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Codigo de tu amigo',
              hintText: 'WLOS-AB12CD34',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(textController.text),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    textController.dispose();

    if (!mounted || referralCode == null) {
      return;
    }

    final message = widget.controller.redeemReferralCode(referralCode);
    _showMessage(message);
  }

  Future<void> _copyReferralCode() async {
    final code = widget.controller.referralCode;

    if (code.isEmpty) {
      _showMessage('Tu codigo aun se esta generando.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      _showMessage('Codigo copiado: $code');
    }
  }

  void _removeWatermark() {
    final message = widget.controller.removeWatermarkForCurrentUser();
    _showMessage(message);
  }

  Future<void> _purchaseUnlock() async {
    final navigatorContext = _navigatorKey.currentContext;

    if (navigatorContext == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
          context: navigatorContext,
          builder: (context) {
            return AlertDialog(
              title: const Text('Pago unico App Store'),
              content: Text(
                'Esta opcion quita la marca de agua para siempre por CLP ${WallOsController.oneTimeUnlockPriceClp}.\n\n'
                'El cobro se configura como compra no consumible en App Store Connect: '
                '${WallOsController.oneTimeUnlockProductId}.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Pagar CLP 5.000'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    final message = await widget.controller.purchaseWatermarkRemovalWithAppStore();
    _showMessage(message);
  }

  Future<void> _applySelectedWallpaper() async {
    final selected = _selectedWallpaper;
    if (selected == null) {
      _showMessage('Selecciona un wallpaper primero.');
      return;
    }

    final message = await widget.controller.applyWallpaper(selected);
    if (mounted) {
      _showMessage(message);
    }
  }

  Future<void> _supportCreator([WallpaperItem? wallpaper]) async {
    final target = wallpaper ?? _selectedWallpaper;
    if (target == null) {
      _showMessage('Selecciona un wallpaper para apoyar a su creador.');
      return;
    }

    if (target.supportUrl.isEmpty) {
      _showMessage('No se pudo abrir el enlace de apoyo.');
      return;
    }

    try {
      final result = await Process.run('open', [target.supportUrl]);
      if (result.exitCode != 0 && mounted) {
        _showMessage('No fue posible abrir el enlace de donacion.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No fue posible abrir el enlace de donacion.');
      }
    }
  }

  void _showMessage(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NavigationPanel extends StatelessWidget {
  const _NavigationPanel({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        labelType: NavigationRailLabelType.all,
        leading: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: SvgPicture.asset('assets/brand/wallos-logo.svg'),
              ),
              const SizedBox(height: 8),
              Text('WallOs', style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: Text('Explore'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: Text('Favoritos'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: Text('Ajustes'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: Text('FAQ'),
          ),
        ],
      ),
    );
  }
}

class _CatalogSection extends StatelessWidget {
  const _CatalogSection({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.items,
    required this.controller,
    required this.isLoading,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<WallpaperItem> items;
  final WallOsController controller;
  final bool isLoading;
  final ValueChanged<WallpaperItem> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : WallpaperGrid(items: items, controller: controller, onSelect: onSelect),
        ),
      ],
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListView(
      children: [
        Text('Preguntas frecuentes', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Respuestas rapidas sobre marca de agua, soporte y roadmap de WallOs.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
        ),
        const SizedBox(height: 18),
        const _FaqCard(
          question: 'Como quito la marca de agua?',
          answer:
              'Tienes dos opciones: completar 3 recomendaciones validas con codigos unicos o usar pago unico de CLP 5.000 por App Store.',
        ),
        const SizedBox(height: 10),
        const _FaqCard(
          question: 'Como aplico una imagen como fondo de pantalla?',
          answer:
              'Selecciona un wallpaper en Explore y luego presiona "Aplicar como fondo" en el panel derecho.',
        ),
        const SizedBox(height: 10),
        const _FaqCard(
          question: 'Hay soporte activo durante 2026?',
          answer:
              'Si. WallOs mantiene soporte y mejoras continuas durante todo 2026 para la version macOS.',
        ),
        const SizedBox(height: 10),
        const _FaqCard(
          question: 'Van a lanzar version para moviles y tablets?',
          answer:
              'Si. El roadmap contempla expansion a iPhone, iPad y tablets en siguientes fases del producto.',
        ),
      ],
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              answer,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatermarkFooterNotice extends StatelessWidget {
  const _WatermarkFooterNotice();

  @override
  Widget build(BuildContext context) {
    return _ImageWatermarkHint(text: WallOsController.watermarkHintText);
  }
}

class _ImageWatermarkHint extends StatelessWidget {
  const _ImageWatermarkHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}

class _AppFooter extends StatelessWidget {
  const _AppFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Copyright 2026 WallOs. Todos los derechos reservados.',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _InspectorPanel extends StatelessWidget {
  const _InspectorPanel({
    required this.controller,
    required this.selectedWallpaper,
    required this.onApplyWallpaper,
    required this.onRedeemCode,
    required this.onCopyCode,
    required this.onPurchaseUnlock,
    required this.onRemoveWatermark,
    required this.onSupportCreator,
  });

  final WallOsController controller;
  final WallpaperItem? selectedWallpaper;
  final VoidCallback onApplyWallpaper;
  final VoidCallback onRedeemCode;
  final VoidCallback onCopyCode;
  final VoidCallback onPurchaseUnlock;
  final VoidCallback onRemoveWatermark;
  final VoidCallback onSupportCreator;

  @override
  Widget build(BuildContext context) {
    final progress =
      (controller.referralCount / WallOsController.referralGoal).clamp(0.0, 1.0).toDouble();
    final selected = selectedWallpaper;
    final resolutionText = selected == null || selected.width <= 0 || selected.height <= 0
        ? 'Sin datos disponibles'
        : '${selected.width} x ${selected.height} px';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                const Icon(Icons.image_search_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Detalle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (selected == null)
              Text(
                'Presiona cualquier wallpaper para ver sus datos aqui.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          selected.previewAssetPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (controller.watermarkVisible)
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: _ImageWatermarkHint(
                            text: WallOsController.watermarkHintText,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                selected.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _InfoRow(label: 'Dimensiones', value: resolutionText),
              _InfoRow(label: 'Subido por', value: selected.uploadedBy),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: onApplyWallpaper,
                icon: const Icon(Icons.wallpaper_outlined),
                label: const Text('Aplicar como fondo'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onSupportCreator,
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text('Apoyar al creador'),
              ),
            ],
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.workspace_premium_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Referidos por codigo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Desbloquea sin marca de agua con 3 recomendaciones validas o con pago unico App Store.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.38),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_2, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        controller.referralCode.isEmpty ? 'Generando codigo...' : controller.referralCode,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onCopyCode,
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Copiar codigo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRedeemCode,
                    icon: const Icon(Icons.redeem_outlined),
                    label: const Text('Ingresar codigo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              'Canjes validos: ${controller.referralCount}/${WallOsController.referralGoal}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            if (controller.redeemedCodes.isEmpty)
              Text(
                'Todavia no has canjeado codigos.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              )
            else
              ...controller.redeemedCodes.take(6).map(
                (code) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.38),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.verified,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(code),
                      subtitle: const Text('Codigo canjeado correctamente'),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: onRemoveWatermark,
              icon: Icon(
                controller.watermarkRemoved ? Icons.lock_open : Icons.lock_outline,
              ),
              label: Text(
                controller.watermarkRemoved
                    ? 'Marca de agua desactivada'
                    : 'Desbloquear con 3 codigos',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: controller.watermarkRemoved ? null : onPurchaseUnlock,
              icon: const Icon(Icons.payments_outlined),
              label: Text(
                controller.unlockedByPurchase
                    ? 'Pago unico completado'
                    : 'Pago unico CLP 5.000 (App Store)',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cobro no consumible via App Store.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 98,
            child: Text(
              '$label:',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
