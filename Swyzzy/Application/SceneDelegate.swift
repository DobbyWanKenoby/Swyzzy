//
//  SceneDelegate.swift
//  Swyzzy
//
//  Created by Vasily Usov on 20.09.2021.
//

import UIKit
import SwiftCoordinatorsKit
import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // Swin
    
    var assembler = Assembler([BaseAssembly(),
                              AuthProvideAssembly()])
    
    var resolver: Resolver {
        assembler.resolver
	}
    
    /// Главный координатор сцены
    lazy var coordinator: SceneCoordinator = {
        return SceneCoordinator(appCoordinator: (UIApplication.shared.delegate as! AppDelegate).coordinator, window: window!)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else {
            return
        }
        window.windowScene = windowScene

		// Запуск потока координатор
		coordinator.startFlow(withWork: {
			self.createAlertCoordinator()
		})
        
        checkUserDidAuth()
        self.coordinator.presenter = UIViewController()
        startFlowMainCoordinator()
    }
    
    fileprivate func startFlowMainCoordinator() {
        // создание координатора основного потока
        let mainFlowCoordinator = MainFlowCoordinator(rootCoordinator: coordinator, assembler: assembler)
        mainFlowCoordinator.startFlow()
        window?.makeKeyAndVisible()
    }
    
    // проверка, авторизован ли пользователь ранее
    fileprivate func checkUserDidAuth() {
        // Проверяем, авторизованилb пользователь
        // Если авторизован
        let baseAuthProvider = AuthProviderFactory.getBaseAuthProvider(resolver: resolver)
        // Автоматическая деавторизация для схемы "SwyzzyLogout"
        if ProcessInfo.processInfo.environment["auto_logout"] == "true" {
            baseAuthProvider.logout()
        } else {
            let authProvider = resolver.resolve(AuthProviderProtocol.self)!
            if authProvider.isAuth {
                assembler.apply(assembly: UserAssembly())
            }
        }
    }

	// создаем координатор всплывающих сообщений
	fileprivate func createAlertCoordinator() {
		let alertCoordinator = AlertCoordinator(rootCoordinator: coordinator, resolver: resolver)
		alertCoordinator.startFlow(withWork: nil, finishCompletion: nil)
	}

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

