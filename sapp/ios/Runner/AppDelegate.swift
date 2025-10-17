import Flutter
import UIKit
import GoogleMaps
import flutter_downloader

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAZ7hMgw54uBeLQiLLL3FdhoMg9247C1Zk")
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    
    // Register for remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle APNS token registration
  override func application(_ application: UIApplication, 
                           didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Pass APNS token to Firebase
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  override func application(_ application: UIApplication,
                           didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error)")
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
