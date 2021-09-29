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
    
    lazy var firebaseCoordinator: Coordinator = {
        FirebaseCoordinator(rootCoordinator: coordinator, options: [])
    }()
    
    var internationalizationCoordinator: Coordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        firebaseCoordinator.startFlow(withWork: nil, finishCompletion: nil)
        internationalizationCoordinator = InternationalizationCoordinator(rootCoordinator: coordinator, options: [])
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

