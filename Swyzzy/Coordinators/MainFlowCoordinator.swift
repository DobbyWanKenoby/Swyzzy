import UIKit
import SwiftCoordinatorsKit

/*
 MainFlowCoordinator - Координатор основного потока выполнения экземпляра приложения.
 После запуска приложения и создания AppCoordinator, SceneCoordinator, данный координатор является основным управляющим в рамках экзмепляра приложения (сцены)
 */

protocol MainFlowCoordinatorProtocol: BasePresenter, Transmitter {}

class MainFlowCoordinator: BasePresenter, MainFlowCoordinatorProtocol {
    var edit: ((Signal) -> Signal)?
    
    override var presenter: UIViewController? {
        didSet {
            (rootCoordinator as! SceneCoordinator).presenter = presenter
        }
    }
    
    required init(rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: options)
    }
    
    public override init(rootCoordinator: Coordinator? = nil) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: [])
    }
    
    required public init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil) {
        fatalError("init(presenter:rootCoordinator:) has not been implemented")
    }
    
    required public override init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        fatalError("init(presenter:rootCoordinator:options:) has not been implemented")
    }
    
    override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        super.startFlow(withWork: work, finishCompletion: finishCompletion)
        
        // Запускаем координатор Инициализации
        
        let initializatorCoordinator = InitializatorCoordinator(rootCoordinator: self)
        // С помощью следующей строки кода
        // базовый контроллер InitializatorCoordinator станет базовым контроллером Scene Coordinator
        self.presenter = initializatorCoordinator.presenter
        // Запуск потока InitializatorCoordinator
        initializatorCoordinator.startFlow(withWork: nil, finishCompletion: {
            
            // TODO: По окончании работы координатора необходимо определять авторизован ли пользователь и в зависимости от этого вызывать соответствующий координатор
        
        })
            
            
//                                            // По окончании работы координатора инициализации
//                                            // должен начать работу FunctionalCoordinator и отобразиться интерфейс приложения
//                                            let functionalCoordinator = CoordinatorFactory.getFunctionalCoordinator(rootCoordinator: self)
//                                            self.route(from: self.presenter!, to: functionalCoordinator.presenter!, method: .presentFullScreen) {}
//                                            functionalCoordinator.startFlow()
//

    }
    
}
