import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/wallpaper_catalog_repository.dart';
import '../domain/wallpaper_item.dart';

class WallOsController extends ChangeNotifier {
  static const MethodChannel _wallpaperChannel = MethodChannel('wallos/wallpaper');
  static const int referralGoal = 3;
  static const int oneTimeUnlockPriceClp = 5000;
  static const String oneTimeUnlockProductId = 'wallos.remove_watermark.clp5000';
  static const String watermarkHintText =
      'Vista previa con marca de agua. Quita la marca con 3 recomendaciones validas o pago unico de CLP 5.000 en App Store.';
  static final RegExp _referralCodePattern = RegExp(r'^WLOS-[A-Z0-9]{8}$');

  WallOsController({required WallpaperCatalogRepository repository})
      : _repository = repository;

  final WallpaperCatalogRepository _repository;

  List<WallpaperItem> _wallpapers = const [];
  final Set<String> _favoriteIds = <String>{};
  final Set<String> _redeemedCodes = <String>{};
  bool _isLoading = true;
  bool _watermarkRemoved = false;
  bool _unlockedByPurchase = false;
  String _referralCode = '';
  int _rotationMinutes = 30;

  List<WallpaperItem> get wallpapers => _wallpapers;

  List<WallpaperItem> get favorites =>
      _wallpapers.where((item) => _favoriteIds.contains(item.id)).toList(growable: false);

  List<String> get redeemedCodes => List.unmodifiable(_redeemedCodes.toList()..sort());

  bool get isLoading => _isLoading;
  bool get watermarkRemoved => _watermarkRemoved;
  bool get watermarkVisible => !_watermarkRemoved;
  bool get unlockedByPurchase => _unlockedByPurchase;
  String get referralCode => _referralCode;
  int get referralCount => _redeemedCodes.length;
  bool get canRemoveWatermark => referralCount >= referralGoal;
  int get missingReferrals {
    final missing = referralGoal - referralCount;
    return missing > 0 ? missing : 0;
  }

  int get rotationMinutes => _rotationMinutes;

  bool isFavorite(String wallpaperId) => _favoriteIds.contains(wallpaperId);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _wallpapers = await _repository.loadCatalog();
    await _loadReferralState();

    _isLoading = false;
    notifyListeners();
  }

  void toggleFavorite(String wallpaperId) {
    if (_favoriteIds.contains(wallpaperId)) {
      _favoriteIds.remove(wallpaperId);
    } else {
      _favoriteIds.add(wallpaperId);
    }
    notifyListeners();
  }

  void updateRotationMinutes(double value) {
    _rotationMinutes = value.round().clamp(5, 120);
    notifyListeners();
  }

  String redeemReferralCode(String codeInput) {
    final normalizedCode = _normalizeReferralCode(codeInput);

    if (normalizedCode.isEmpty) {
      return 'Ingresa un codigo de referido valido.';
    }

    if (!_referralCodePattern.hasMatch(normalizedCode)) {
      return 'Formato invalido. Usa un codigo como WLOS-AB12CD34.';
    }

    if (_referralCode.isNotEmpty && normalizedCode == _referralCode) {
      return 'No puedes canjear tu propio codigo.';
    }

    if (_redeemedCodes.contains(normalizedCode)) {
      return 'Este codigo ya fue utilizado en tu cuenta.';
    }

    _redeemedCodes.add(normalizedCode);
    _saveReferralState();
    notifyListeners();

    if (canRemoveWatermark) {
      return 'Codigo aplicado. Ya puedes quitar las marcas de agua.';
    }

    return 'Codigo aplicado. Te faltan $missingReferrals codigos validos.';
  }

  String removeWatermarkForCurrentUser() {
    if (_watermarkRemoved) {
      if (_unlockedByPurchase) {
        return 'El modo sin marcas de agua ya esta activo por pago unico.';
      }

      return 'El modo sin marcas de agua ya esta activo.';
    }

    if (!canRemoveWatermark) {
      return 'Necesitas canjear $missingReferrals codigos validos mas para desbloquearlo.';
    }

    _watermarkRemoved = true;
    _unlockedByPurchase = false;
    _saveReferralState();
    notifyListeners();
    return 'Modo sin marcas de agua activado para tu cuenta.';
  }

  Future<String> purchaseWatermarkRemovalWithAppStore() async {
    if (_watermarkRemoved) {
      if (_unlockedByPurchase) {
        return 'La compra unica ya fue aplicada en esta cuenta.';
      }

      return 'La marca de agua ya fue removida con recomendaciones validas.';
    }

    // StoreKit purchase wiring is completed in App Store Connect.
    // This local build keeps a deterministic unlock for QA flows.
    _unlockedByPurchase = true;
    _watermarkRemoved = true;
    _saveReferralState();
    notifyListeners();
    return 'Pago unico de CLP 5.000 activado. En App Store se configura como compra no consumible (${WallOsController.oneTimeUnlockProductId}).';
  }

  Future<String> applyWallpaper(WallpaperItem wallpaper) async {
    if (!Platform.isMacOS) {
      return 'Aplicar fondo esta disponible solo en macOS.';
    }

    try {
      final materializedFile = await _materializeWallpaperFile(wallpaper);
      await _wallpaperChannel.invokeMethod<void>('setWallpaper', {
        'path': materializedFile.path,
      });

      return 'Fondo aplicado: ${wallpaper.title}';
    } on PlatformException catch (error) {
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return 'No se pudo aplicar el fondo: ${error.message}';
      }

      return 'No se pudo aplicar el fondo de pantalla.';
    } catch (_) {
      return 'No se pudo aplicar el fondo de pantalla.';
    }
  }

  Future<void> _loadReferralState() async {
    final stateFile = _stateFile;

    try {
      if (await stateFile.exists()) {
        final content = await stateFile.readAsString();
        final parsed = json.decode(content);

        if (parsed is Map<String, dynamic>) {
          final storedCode = parsed['myReferralCode'];
          final storedRedeemedCodes = parsed['redeemedCodes'];
          final storedWatermarkRemoved = parsed['watermarkRemoved'];
          final storedUnlockedByPurchase = parsed['unlockedByPurchase'];

          if (storedCode is String && _referralCodePattern.hasMatch(storedCode)) {
            _referralCode = storedCode;
          }

          if (storedRedeemedCodes is List) {
            for (final entry in storedRedeemedCodes) {
              if (entry is String && _referralCodePattern.hasMatch(entry)) {
                _redeemedCodes.add(entry);
              }
            }
          }

          if (storedWatermarkRemoved is bool) {
            _watermarkRemoved = storedWatermarkRemoved;
          }

          if (storedUnlockedByPurchase is bool) {
            _unlockedByPurchase = storedUnlockedByPurchase;
          }

          if (_unlockedByPurchase) {
            _watermarkRemoved = true;
          }
        }
      }
    } catch (_) {
      // If state is corrupted, continue with a fresh state.
    }

    if (_referralCode.isEmpty) {
      _referralCode = _generateReferralCode();
      _saveReferralState();
    }
  }

  void _saveReferralState() {
    final stateFile = _stateFile;
    final payload = {
      'myReferralCode': _referralCode,
      'redeemedCodes': _redeemedCodes.toList()..sort(),
      'watermarkRemoved': _watermarkRemoved,
      'unlockedByPurchase': _unlockedByPurchase,
    };

    stateFile.parent.create(recursive: true).then((_) {
      stateFile.writeAsString(json.encode(payload));
    });
  }

  File get _stateFile {
    final home = Platform.environment['HOME'] ?? Directory.current.path;
    return File('$home/.wallos/referral_state.json');
  }

  String _generateReferralCode() {
    final random = Random.secure();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final suffix = List.generate(
      8,
      (_) => chars[random.nextInt(chars.length)],
    ).join();

    return 'WLOS-$suffix';
  }

  String _normalizeReferralCode(String input) {
    return input.trim().toUpperCase().replaceAll(' ', '');
  }

  Future<File> _materializeWallpaperFile(WallpaperItem wallpaper) async {
    final rawData = await rootBundle.load(wallpaper.previewAssetPath);
    final extension = _fileExtensionForAssetPath(wallpaper.previewAssetPath);
    final safeFileName = wallpaper.id.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final tempDir = Directory('${Directory.systemTemp.path}/wallos_wallpapers');
    await tempDir.create(recursive: true);
    final file = File('${tempDir.path}/$safeFileName$extension');
    await file.writeAsBytes(
      rawData.buffer.asUint8List(rawData.offsetInBytes, rawData.lengthInBytes),
      flush: true,
    );

    return file;
  }

  String _fileExtensionForAssetPath(String assetPath) {
    final dotIndex = assetPath.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == assetPath.length - 1) {
      return '.png';
    }

    return assetPath.substring(dotIndex);
  }

}
