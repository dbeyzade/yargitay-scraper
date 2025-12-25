import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    // Tam ekran modunu etkinleştir
    self.toggleFullScreen(nil)
    
    // Tam ekran düğmesini gizle (kullanıcı tam ekrandan çıkamasın)
    self.styleMask.insert(.fullScreen)
    self.collectionBehavior = .fullScreenPrimary

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
