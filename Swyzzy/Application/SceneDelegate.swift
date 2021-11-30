//
//  SceneDelegate.swift
//  Swyzzy
//
//  Created by Vasily Usov on 20.09.2021.
//

import UIKit
import SwiftCoordinatorsKit
import Swinject
import Combine
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate, Injectable {

    var window: UIWindow?
    
    private var assembler = Assembler([
        BaseAssembly(),
        UserBuilderAssembly(),
        AuthAssembly(),
    ])

    private var resolver: Resolver {
        assembler.resolver
    }

    private var mainFlowCoordinator: MainFlowCoordinatorProtocol!

    @Injected() private var userBuilder: UserBuilder!

    // основной издатель приложения
    private var appPublisher: PassthroughSubject<AppEvents, Never> {
        resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
    }

    // подписчик на события основного издателя приложения
    private var appEventsSubscriber: AnyCancellable!

    override init() {
        super.init()
        injectServices(resolver)
        createSubscribers()
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

        try? Auth.auth().signOut()
        
        if ProcessInfo.processInfo.environment["auto_logout"] == "true" {
            try? Auth.auth().signOut()
        }
        coordinator.presenter = SplashViewController.getInstance()
        mainFlowCoordinator = MainFlowCoordinator(rootCoordinator: coordinator, resolver: resolver)
        showNextController(window)
        window.makeKeyAndVisible()
    }

    private func showNextController(_ window: UIWindow) {
        userBuilder.createUserIfCan { [self] result in
            switch result {
            case .success(let user):
                assembler.apply(assembly: AuthUserAssembly(user))
            case .failure(let error):
                log(.console, message: error.localizedDescription, source: self)
            }
            mainFlowCoordinator.startFlow()
        }
    }

    // Создание подписчиков
    private func createSubscribers() {
        // Подписчик на событие "Пользователь залогинился"
        appEventsSubscriber = appPublisher.sink(receiveValue: { event in
            log(.console, message: "Receive publish event", source: self)
            switch event {
            case .userLogin:
                log(.console, message: "User did login", source: self)
                self.showNextController(self.window!)
//                self.userBuilder.createUserIfCan { result in
//                    switch result {
//                    case .success(let user):
//                        self.assembler.apply(assembly: AuthUserAssembly(user))
//                        self.mainFlowCoordinator.startFlow()
//                    case .failure(let error):
//                        log(.console, message: error.localizedDescription, source: self)
//                    }
//                }
            default:
                log(.console, message: "Receive unknown publish event", source: self)
                return
            }
        })
    }

    

	// создаем координатор всплывающих сообщений
	fileprivate func createAlertCoordinator() {
		let alertCoordinator = AlertCoordinator(rootCoordinator: coordinator, resolver: resolver)
		alertCoordinator.startFlow(withWork: nil, finishCompletion: nil)
	}
}

