import UIKit
import SwiftCoordinatorsKit
import Swinject
import Combine
import Firebase

/*
 MainFlowCoordinator - Координатор основного потока выполнения экземпляра приложения.
 После запуска приложения и создания AppCoordinator, SceneCoordinator, данный координатор является основным управляющим в рамках экзмепляра приложения (сцены)
 */

protocol MainFlowCoordinatorProtocol: BasePresenter, Transmitter {
    init(rootCoordinator: Coordinator, assembler: Assembler)
}

class MainFlowCoordinator: BasePresenter, MainFlowCoordinatorProtocol {
    
    private var assembler: Assembler
    private var resolver: Resolver {
        assembler.resolver
    }

	// объект-пользователь
    private var _user: UserProtocol?
	private var user: UserProtocol? {
        get {
            if let user = resolver.resolve(UserProtocol.self) {
                _user = user
            }
            return _user
        }
        set {
            _user = newValue
        }
	}
    
    // Показывает, были ли загружены данные с сервера и на сервер
    private var dataDidSync: Bool = false

	// основной издатель приложения
	private var appPublisher: PassthroughSubject<AppEvents, Never> {
		resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
	}

	// подписчик на события основного издателя приложения
	private var appEventsSubscriber: AnyCancellable!

	var edit: ((Signal) -> Signal)?

	override var presenter: UIViewController? {
		get {
			(rootCoordinator as! SceneCoordinator).presenter
		}
		set {
			(rootCoordinator as! SceneCoordinator).presenter = newValue
		}
	}

    required init(rootCoordinator: Coordinator, assembler: Assembler) {
		self.assembler = assembler
		super.init(rootCoordinator: rootCoordinator)
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)
        Task(priority: TaskPriority.high) {
            createSubscribers()
            showNextController(presentFrom: self.presenter!)
        }
        
	}

	// Создание подписчиков
	private func createSubscribers() {
		// Подписчик на событие "Пользователь залогинился"
        appEventsSubscriber = appPublisher.sink(receiveValue: { event in
            switch event {
            case .userLogin (let sourceController):
                self.dataDidSync = false
                self.assembler.apply(assembly: UserAssembly())
                self.showNextController(presentFrom: sourceController)
            default:
                return
            }
        })
	}

	// Отображает следующий экран
	private func showNextController(presentFrom: UIViewController) {

		takeNextCoordinatorAnd { coordinator in
			if let authCoordinator = coordinator as? AuthCoordinatorProtocol {
				// координатор авторизации должен наложиться сверху, чтобы предыдущая "слиться" с предыдущей анимацией
				self.presenter = authCoordinator.presenter
				authCoordinator.startFlow()

			} else if let initCoordinator = coordinator as? InitializatorCoordinator {
				initCoordinator.startFlow {
                    if presentFrom is PhoneCodeController {
                        self.route(from: presentFrom, to: initCoordinator.presenter!, method: .presentFullScreen, completion: nil)
                    } else {
                        self.presenter = initCoordinator.presenter!
                    }
				} finishCompletion:  {
					self.showNextController(presentFrom: initCoordinator.presenter!)
				}

			} else if let funcCoordinator = coordinator as? FunctionalCoordinatorProtocol {
				funcCoordinator.startFlow {
					self.route(from: presentFrom, to: (coordinator as! Presenter).presenter!, method: .presentFullScreen, completion: nil)
				} finishCompletion: {}

			} else {
				coordinator.startFlow {
					self.route(from: presentFrom, to: (coordinator as! Presenter).presenter!, method: .presentFullScreen, completion: nil)
				}
			}
		}
	}

	private func takeNextCoordinatorAnd(doWork closure: @escaping (Coordinator) -> Void) {
        
        if let user = user {
            if user.dataNeedSync {
                closure(getInitialCoordinator())
            } else {
                
            }
        } else {
            if !dataDidSync {
                dataDidSync = true
                closure(getInitialCoordinator())
            } else {
                closure(getAuthCoordinator())
            }
        }
    
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

	private func sendErrorMessage(_ text: String) {
		let alert = AppEvents.ShowEventType.withTitleAndText(title: Localization.Error.error.localized, message: text)
		let button = AppEvents.ShowEventButton(title: Localization.Base.repeatit.localized, style: .cancel, handler: {
			self.showNextController(presentFrom: self.presenter!)
		})
		appPublisher.send(AppEvents.showEvent(onScreen: self.presenter!, type: alert, buttons: [button]))
	}

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
