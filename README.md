# sentinelshq

A CyberSentinels Management Platform.

For iOS

1. Put Google Service plist into ios/Runner via Xcode

2. AppDelegate.swift :
import Flutter
import UIKit
import FirebaseCore
import FirebaseFirestore

@main
@objc class AppDelegate: FlutterAppDelegate {
override func application(
_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
FirebaseApp.configure()  // 🔥 Ensure Firebase is initialized
GeneratedPluginRegistrant.register(with: self)
return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
}

3. info.plist change - add necessary permission.
4. podfile necessary changes
5. add libs frameworks manually in Runner/Buildphases/link binary with libs.
6. cd ios
   pod install --repo-update
   cd ..
   flutter clean
   flutter pub get