/*
 FunctionalCoordinator - координатор, предназначенный для выполнения приложением своих функций
 Запускается после InitializatorCoordinator и отображает интерфейс приложения
 */

import UIKit
import SwiftCoordinatorsKit
import Swinject
import Combine

protocol FunctionalCoordinatorProtocol: BasePresenter, Transmitter {
	// Swinject Resolver
	var resolver: Resolver! { get set }
}

final class FunctionalCoordinator: BasePresenter, FunctionalCoordinatorProtocol {

	// MARK: - Properties

	var resolver: Resolver!

	// объект-пользователь
	lazy var user: UserProtocol = {
		resolver.resolve(UserProtocol.self)!
	}()

	// основной издатель приложения
	private var appPublisher: PassthroughSubject<AppEvents, Never> {
		resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
	}

	var edit: ((Signal) -> Signal)?

	// используется для доступа к презентеру, как к Navigation Controller
	// свойство - синтаксический сахар
	var navigationPresenter: UINavigationController {
		presenter as! UINavigationController
	}

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
		createControllers()
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)
	}

	private func createControllers() {
		presenter = FunctionalTabBarController.getInstance()
		let moreController = MoreController.getInstance()
		(presenter as! UITabBarController).setViewControllers([moreController], animated: true)
		
	}

}
