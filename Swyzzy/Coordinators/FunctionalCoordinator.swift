/*
 FunctionalCoordinator - координатор, предназначенный для выполнения приложением своих функций
 Запускается после InitializatorCoordinator и отображает интерфейс приложения
 */

import UIKit
import SwiftCoordinatorsKit
import Swinject

protocol FunctionalCoordinatorProtocol: BasePresenter, Transmitter {}

final class FunctionalCoordinator: BasePresenter, FunctionalCoordinatorProtocol {
    var edit: ((Signal) -> Signal)?
    
    private lazy var DI: Resolver = {
        Assembler([UserAssembly()]).resolver
    }()
    
    // используется для доступа к презентеру, как к Navigation Controller
    // свойство - синтаксический сахар
    var navigationPresenter: UINavigationController {
        presenter as! UINavigationController
    }
    
    required init(rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: options)
        presenter = UINavigationController()
    }
    
    required public init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil) {
        fatalError("init(presenter:rootCoordinator:) has not been implemented")
    }
    
    @discardableResult
    public override init(rootCoordinator: Coordinator? = nil) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: [])
        presenter = UINavigationController()
    }
    
    public override init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        fatalError("init(presenter:rootCoordinator:options:) has not been implemented")
    }
    
    override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        super.startFlow(withWork: work, finishCompletion: finishCompletion)
        
        let user = DI.resolve(UserProtocol.self)!
        
        if user.isAuth {
            let controller = AuthController.getInstance()
            navigationPresenter.viewControllers.append(controller)
        } else {
            let controller = InitializationController.getInstance()
            controller.view.backgroundColor = .red
            navigationPresenter.viewControllers.append(controller)
        }
        
    }

    
}
