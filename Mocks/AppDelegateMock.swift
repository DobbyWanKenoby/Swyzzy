//
//  AppDelegate.swift
//  Swyzzy
//
//  Created by Vasily Usov on 20.09.2021.
//

import UIKit
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
        internationalizationCoordinator = InternationalizationCoordinator(rootCoordinator: coordinator, options: [])
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
}

