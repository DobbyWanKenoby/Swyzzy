/*
 FunctionalCoordinator - координатор, предназначенный для выполнения приложением своих функций
 Запускается после InitializatorCoordinator и отображает интерфейс приложения
 */

import UIKit
import SwiftCoordinatorsKit
import Swinject

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
    
    var edit: ((Signal) -> Signal)?
    
    // используется для доступа к презентеру, как к Navigation Controller
    // свойство - синтаксический сахар
    var navigationPresenter: UINavigationController {
        presenter as! UINavigationController
    }
    
    required init(rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: options)
        createControllers()
    }
    
    required public init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil) {
        fatalError("init(presenter:rootCoordinator:) has not been implemented")
    }
    
    @discardableResult
    public override init(rootCoordinator: Coordinator? = nil) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: [])
        createControllers()
    }
    
    public override init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        fatalError("init(presenter:rootCoordinator:options:) has not been implemented")
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
