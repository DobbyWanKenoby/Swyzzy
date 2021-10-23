import UIKit
import SwiftCoordinatorsKit
import Swinject
import Combine

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

		// Запускаем координатор Инициализации
		let initializationCoordinator = InitializatorCoordinator(rootCoordinator: self, resolver: resolver)
		// С помощью следующей строки кода
		// базовый контроллер InitializatorCoordinator станет базовым контроллером Scene Coordinator
		self.presenter = initializationCoordinator.presenter
		// Запуск потока InitializatorCoordinator
		initializationCoordinator.startFlow(finishCompletion:  {
			// Определяем, авторизован ли пользователь
			if self.user.isAuth == false {
				self.createAndStartAuthCoordinator()
			} else {
				self.createAndStartFunctionalCoordinator()
			}
		})
	}

	// Создание подписчиков
	private func createSubscribers() {
		appEventsSubscriber = appPublisher.sink(receiveValue: { event in
			switch event {
			case .userLogin (let controller):
				let v = UIViewController()
				v.view.backgroundColor = .red
				let functionalCoordinator = FunctionalCoordinator(rootCoordinator: self)
				functionalCoordinator.resolver = self.resolver

				self.route(from: controller, to: functionalCoordinator.presenter!, method: .presentFullScreen) {}
				functionalCoordinator.startFlow()
			}
		})
	}

	private func createAndStartAuthCoordinator() {
		let authCoordinator = AuthCoordinator(rootCoordinator: self, resolver: self.resolver)
		self.presenter = authCoordinator.presenter
		authCoordinator.startFlow(withWork: nil) {
			self.createAndStartFunctionalCoordinator()
		}
	}

	private func createAndStartFunctionalCoordinator() {
		let functionalCoordinator = FunctionalCoordinator(rootCoordinator: self)
		functionalCoordinator.resolver = resolver
		self.route(from: self.presenter!, to: functionalCoordinator.presenter!, method: .presentFullScreen) {}
		functionalCoordinator.startFlow()
	}

}
