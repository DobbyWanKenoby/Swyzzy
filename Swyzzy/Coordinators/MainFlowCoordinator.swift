import UIKit
import SwiftCoordinatorsKit
import Swinject
import Combine
import Firebase

/*
 MainFlowCoordinator - Координатор основного потока выполнения экземпляра приложения.
 После запуска приложения и создания AppCoordinator, SceneCoordinator, данный координатор является основным управляющим в рамках экзмепляра приложения (сцены)
 */

protocol MainFlowCoordinatorProtocol: BasePresenter {
    init(rootCoordinator: Coordinator, resolver: Resolver)

}

class MainFlowCoordinator: BasePresenter, MainFlowCoordinatorProtocol, Injectable {

    private var resolver: Resolver

    private var user: User? {
        resolver.resolve(User.self)
    }

    //@Injected() private var user: User?

	override var presenter: UIViewController? {
		get {
			(rootCoordinator as! SceneCoordinator).presenter
		}
		set {
			(rootCoordinator as! SceneCoordinator).presenter = newValue
		}
	}

    required init(rootCoordinator: Coordinator, resolver: Resolver) {
        self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
        log(.console, message: "Create instance", source: self)
        injectServices(resolver)
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        log(.console, message: "Coordinator did start own flow", source: self)
		super.startFlow(withWork: work, finishCompletion: finishCompletion)
        showNextController(presentFrom: self.presenter!)
	}

	// Отображает следующий экран
    private func showNextController(presentFrom: UIViewController) {

        self.takeNextCoordinatorWithWork { coordinator in
            log(.console, message: "Selected \(coordinator)", source: self)
            if let authCoordinator = coordinator as? AuthCoordinatorProtocol {
                // координатор авторизации должен наложиться сверху, чтобы "слиться" с предыдущей анимацией
                self.presenter = authCoordinator.presenter
                authCoordinator.startFlow()

            } else if let initCoordinator = coordinator as? InitializatorCoordinator {
                initCoordinator.startFlow {
                    log(.console, message: "Route from \(presentFrom) to \((coordinator as! Presenter).presenter!)", source: self)
                    if presentFrom is PhoneCodeController {
                        self.route(from: presentFrom, to: initCoordinator.presenter!, method: .presentFullScreen, completion: nil)
                    } else {
                        initCoordinator.presenter?.modalPresentationStyle = .overFullScreen
                        self.presenter?.present(initCoordinator.presenter!, animated: true, completion: nil)
                        //self.presenter = initCoordinator.presenter!
                    }
                } finishCompletion:  {
                    self.showNextController(presentFrom: initCoordinator.presenter!)
                }

            } else if let funcCoordinator = coordinator as? FunctionalCoordinatorProtocol {
                funcCoordinator.startFlow {
                    log(.console, message: "Route from \(presentFrom) to \((coordinator as! Presenter).presenter!)", source: self)
                    self.route(from: presentFrom, to: (coordinator as! Presenter).presenter!, method: .presentFullScreen, completion: nil)
                } finishCompletion: {}
                
            } else if let helloCoordinator = coordinator as? HelloCoordinatorProtocol {
                helloCoordinator.startFlow {
                    log(.console, message: "Route from \(presentFrom) to \((coordinator as! Presenter).presenter!)", source: self)
                    self.route(from: presentFrom, to: (coordinator as! Presenter).presenter!, method: .presentFullScreen, completion: nil)
                } finishCompletion: {
                    return
                }
            
            // Во всех остальных случаях
            // ВАЖНО: Будет вызван startFlow не конкретного координатора, а расширения протокола (диспетчеризация работает)
            // Если трубуется вызывать startFlow именно координатора, то необходтимо добавить блок else if let
            } else {
                coordinator.startFlow {
                    log(.console, message: "Route from \(presentFrom) to \((coordinator as! Presenter).presenter!)", source: self)
                    self.route(from: presentFrom, to: (coordinator as! Presenter).presenter!, method: .presentFullScreen, completion: nil)
                }
            }
        }
    }

    // TODO: Удалить это свйоство, так это по сути хак для анимации экрана входа
    private var needShowAnimatedInitializationScreen: Bool = true

	private func takeNextCoordinatorWithWork(_ closure: @escaping (Coordinator) -> Void) {
        log(.console, message: "Selecting next controller", source: self)
        guard let user = user else {
            if needShowAnimatedInitializationScreen {
                needShowAnimatedInitializationScreen = false
                closure(getInitialCoordinator())
            } else {
                closure(getAuthCoordinator())
            }
            return
        }

        if user.needDownloadDataFromExternalStorage {
            closure(getInitialCoordinator())
        } else if !user.needDownloadDataFromExternalStorage && user.name == "" {
            closure(getHelloCoordinator())
        } else {
            // TODO: functional coordinator
        }
        
//        if let user = user {
//            if user.needDownloadDataFromExternalStorage {
//                closure(getInitialCoordinator())
//            } else if !user.needDownloadDataFromExternalStorage && user.needEnterPrimaryData {
//                closure(getHelloCoordinator())
//            } else if !user.needDownloadDataFromExternalStorage && !user.needEnterPrimaryData {
//                // TODO: functional coordinator
//            } else {
//                fatalError("Этот блок не должен быть запущен")
//            }
//        } else {
//            if !dataDidSync {
//                dataDidSync = true
//                closure(getInitialCoordinator())
//            } else {
//                closure(getAuthCoordinator())
//            }
//        }
    
		// Проверяем, а есть ли данные пользователя в базе
//		guard let id = user.fb?.uid else {
//			return
//		}
//
//		let docRef = Firestore.firestore().collection("users").document("\(id)")
//		docRef.getDocument { (document, error) in
//			guard error == nil else {
//				self.sendErrorMessage(error?.localizedDescription ?? "")
//				return
//			}
//
//			guard let document = document else {
//				self.sendErrorMessage(error?.localizedDescription ?? "")
//				return
//			}
//			// Если данных нет, то грузим экран приветствия
//			if !document.exists {
//				closure(self.getHelloCoordinator())
//			// Если данные есть, то грузим основной экран
//			} else {
//				closure(self.getFunctionalCoordinator())
//			}
//		}
	}

//	private func sendErrorMessage(_ text: String) {
//		let alert = AppEvents.ShowEventType.withTitleAndText(title: Localization.Error.error.localized, message: text)
//		let button = AppEvents.ShowEventButton(title: Localization.Base.repeatit.localized, style: .cancel, handler: {
//			self.showNextController(presentFrom: self.presenter!)
//		})
//		appPublisher.send(AppEvents.showEvent(onScreen: self.presenter!, type: alert, buttons: [button]))
//	}

	private func getHelloCoordinator() -> Coordinator {
		return HelloCoordinator(rootCoordinator: self, resolver: resolver)
	}

	// Возвращает координтор авторизации
	private func getAuthCoordinator() -> Coordinator {
		return AuthCoordinator(rootCoordinator: self, resolver: resolver)
	}

	// Возвращает функциональный координатор
	private func getFunctionalCoordinator() -> Coordinator {
		return FunctionalCoordinator(rootCoordinator: self, resolver: resolver)
	}

	fileprivate func createInitializationCoordinator() {
		// Запускаем координатор Инициализации
		let initializationCoordinator = getInitialCoordinator() as! InitializatorCoordinator
		// С помощью следующей строки кода
		// базовый контроллер InitializatorCoordinator станет базовым контроллером Scene Coordinator
		self.presenter = initializationCoordinator.presenter
		// Запуск потока InitializatorCoordinator
		initializationCoordinator.startFlow(finishCompletion:  { [unowned self] in
			self.showNextController(presentFrom: presenter!)
		})
	}

	private func getInitialCoordinator() -> Coordinator {
		return InitializatorCoordinator(rootCoordinator: self, resolver: resolver)
	}

}
