import UIKit
import SwiftCoordinatorsKit
import Swinject

/*
 MainFlowCoordinator - Координатор основного потока выполнения экземпляра приложения.
 После запуска приложения и создания AppCoordinator, SceneCoordinator, данный координатор является основным управляющим в рамках экзмепляра приложения (сцены)
 */

protocol MainFlowCoordinatorProtocol: BasePresenter, Transmitter {}

class MainFlowCoordinator: BasePresenter, MainFlowCoordinatorProtocol {
    
    // объект-пользователь
    private lazy var user: UserProtocol = {
        DI.resolve(UserProtocol.self)!
    }()
    
    private lazy var DI: Resolver = {
        Assembler([UserAssembly()]).resolver
    }()
    
    var edit: ((Signal) -> Signal)?
    
    override var presenter: UIViewController? {
        didSet {
            (rootCoordinator as! SceneCoordinator).presenter = presenter
        }
    }
    
    required
    init(rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: options)
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
    public override init(rootCoordinator: Coordinator? = nil) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: [])
    }
    
    override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        super.startFlow(withWork: work, finishCompletion: finishCompletion)
        
        // Запускаем координатор Инициализации
        let initializationCoordinator = InitializatorCoordinator(rootCoordinator: self)
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
        self.presenter = authCoordinator.presenter
        authCoordinator.startFlow(withWork: nil) {
            self.createAndStartFunctionalCoordinator()
        }
    }
    
    private func createAndStartFunctionalCoordinator() {
        // TODO: Тут должен быть вывод FunctionalCoordinator
        //let functionalCoordinator = FunctionalCoordinator(rootCoordinator: self)
        //self.route(from: self.presenter!, to: functionalCoordinator.presenter!, method: .presentFullScreen) {}
        //functionalCoordinator.startFlow()
    }
    
}
