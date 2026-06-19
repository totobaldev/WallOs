import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private static let wallpaperChannelName = "wallos/wallpaper"

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    let wallpaperChannel = FlutterMethodChannel(
      name: MainFlutterWindow.wallpaperChannelName,
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    wallpaperChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setWallpaper" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard
        let args = call.arguments as? [String: Any],
        let path = args["path"] as? String,
        !path.isEmpty
      else {
        result(
          FlutterError(
            code: "invalid_args",
            message: "Missing wallpaper path.",
            details: nil
          )
        )
        return
      }

      self?.setDesktopWallpaper(path: path, result: result)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  private func setDesktopWallpaper(path: String, result: @escaping FlutterResult) {
    let imageURL = URL(fileURLWithPath: path)

    guard FileManager.default.fileExists(atPath: imageURL.path) else {
      result(
        FlutterError(
          code: "file_not_found",
          message: "Wallpaper file not found.",
          details: path
        )
      )
      return
    }

    do {
      for screen in NSScreen.screens {
        try NSWorkspace.shared.setDesktopImageURL(imageURL, for: screen, options: [:])
      }

      result(nil)
    } catch {
      result(
        FlutterError(
          code: "set_wallpaper_failed",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }
}
