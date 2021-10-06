//
//  AppDelegate.swift
//  Swyzzy
//
//  Created by Vasily Usov on 20.09.2021.
//

import UIKit
import Firebase
import SwiftCoordinatorsKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Главный координтор приложения
    lazy var coordinator: AppCoordinator = {
        var appCoordinator = AppCoordinator()
        return appCoordinator
    }()
    
    var internationalizationCoordinator: Coordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        internationalizationCoordinator = InternationalizationCoordinator(rootCoordinator: coordinator, options: [])
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Если на устройстве отключен swizzling, то для Firebase используется следующий код
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Если на устройстве отключен swizzling, то для Firebase используется следующий код
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        // Если на устройстве отключен swizzling, то для Firebase используется следующий код
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
}

