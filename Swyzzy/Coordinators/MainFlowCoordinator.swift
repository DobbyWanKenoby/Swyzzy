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
	// Swinject Resolver
	var resolver: Resolver { get set }
}

class MainFlowCoordinator: BasePresenter, MainFlowCoordinatorProtocol {

	// MARK: -Input

	var resolver: Resolver

	// MARK: - Others

	// объект-пользователь
	private var user: UserProtocol {
		resolver.resolve(UserProtocol.self)!
	}

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

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)
		createSubscribers()
		createInitialzationCoordinator()
	}

	// Создание подписчиков
	private func createSubscribers() {
		// Подписчик на событие "Пользователь залогинился"
		appEventsSubscriber = appPublisher.sink(receiveValue: { event in
			switch event {
			case .userLogin (let sourceController):
//				self.appPublisher.send(AppEvents.showEvent(onScreen: sourceController,
//														   title: L.Base.wait.localized,
//														   message: L.Loading.loading.localized))
				self.showNextController(presentFrom: sourceController)
			default:
				return
			}
		})
	}

	// Отображает следующий экран
	private func showNextController(presentFrom: UIViewController) {
		let coordinator = getNextCoordinator()
		// для каждого из будущих контроллеров может быть своя логика отображения

		if let authCoordinator = coordinator as? AuthCoordinatorProtocol {
			// координатор авторизации должен анложиться сверху, чтобы предыдущая "слиться" с предыдущей анимацией
			self.presenter = authCoordinator.presenter
			authCoordinator.startFlow()

		} else if let initCoordinator = coordinator as? InitializatorCoordinator {
			initCoordinator.startFlow {
				self.route(from: presentFrom, to: initCoordinator.presenter!, method: .presentFullScreen, completion: nil)
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

	// Возвращает следующий по порядку координатор
	private func getNextCoordinator() -> Coordinator{
		// если не авторизован
		guard user.isAuth else {
			return getAuthCoordinator()
		}
		// если данные еще не загружены
		guard user.dataDidUpdate else {
			return getInitialCoordinator()
		}
		//если входит впервые
		if checkUserNeedEnterBaseData() {
			return getHelloCoordinator()
		} else {
			return getFunctionalCoordinator()
		}
	}

	private func checkUserNeedEnterBaseData() -> Bool {
		guard let id = user.fb?.uid else {
			return false
		}

		let docRef = Firestore.firestore().collection("users").document("\(id)")
		var result = false
		docRef.getDocument { (document, error) in
			guard let document = document else {
				self.sendErrorMessage(error?.localizedDescription ?? "")
				return
			}
			result = document.exists
		}
		return result
	}

	private func sendErrorMessage(_ text: String) {
		let button = AppEventAlertButton(title: Localization.Base.ok.localized, style: .cancel, handler: nil)
		appPublisher.send(AppEvents.showEvent(onScreen: self.presenter!, title: Localization.Error.error.localized, message: text, buttons: [button]))
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

	fileprivate func createInitialzationCoordinator() {
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
