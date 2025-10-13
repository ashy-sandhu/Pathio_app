import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ⚠️ REPLACE THIS API KEY BEFORE PRODUCTION - This is a temporary key for testing only
    GMSServices.provideAPIKey("AIzaSyAOVYRIgupAurZup5y1PRh8Ismb1A3lLao")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
