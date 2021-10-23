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
	var resolver: Resolver! { get set }
}

class MainFlowCoordinator: BasePresenter, MainFlowCoordinatorProtocol {

	// объект-пользователь
	private lazy var user: UserProtocol = {
		resolver.resolve(UserProtocol.self)!
	}()

	// основной издатель приложения
	private lazy var appPublisher: PassthroughSubject<AppEvents, Never> = {
		resolver.resolve(PassthroughSubject<AppEvents, Never>.self)!
	}()

	var resolver: Resolver! = {
		Assembler([MainAssembly()]).resolver
	}()

	// подписчик на события основного издателя приложения
	private var appEventsSubscriber: AnyCancellable!

	var edit: ((Signal) -> Signal)?

	override var presenter: UIViewController? {
		didSet {
			(rootCoordinator as! SceneCoordinator).presenter = presenter
		}
	}

	required
	init(rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
		super.init(presenter: nil, rootCoordinator: rootCoordinator, options: options)
		appEventsSubscriber = appPublisher.sink(receiveValue: { event in
			switch event {
			case .userLogin:
				print("123123123")
			}
		})

	}

	required
	public init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil) {
		fatalError("init(presenter:rootCoordinator:) has not been implemented")
	}

	required
	public override init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
		fatalError("init(presenter:rootCoordinator:options:) has not been implemented")
	}

	@discardableResult
	public override convenience init(rootCoordinator: Coordinator? = nil) {
		self.init(rootCoordinator: rootCoordinator, options: [])
		//super.init(presenter: nil, rootCoordinator: rootCoordinator, options: [])
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)

		// Запускаем координатор Инициализации
		let initializationCoordinator = InitializatorCoordinator(rootCoordinator: self)
		initializationCoordinator.resolver = resolver
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

	private func createAndStartAuthCoordinator() {
		let authCoordinator = AuthCoordinator(rootCoordinator: self)
		authCoordinator.resolver = resolver
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
