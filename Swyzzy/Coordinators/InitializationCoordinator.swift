/*
 InitializatorCoordinator - координатор инициализации
 Предназначен для выполнения различных процедур инцииализации приложения, например загрузки обновлений из сети
 
 Данный координатор является Презентером, и для отображения процесса инициализации используется вью контроллер, хранящийся в свойстве presenter
 */

import UIKit
import SwiftCoordinatorsKit
import Swinject
import Firebase
import FirebaseAuth

protocol InitializatorCoordinatorProtocol: BasePresenter, Transmitter {}

final class InitializatorCoordinator: BasePresenter, InitializatorCoordinatorProtocol {
    
    // объект-пользователь
    lazy var user: UserProtocol = {
        DI.resolve(UserProtocol.self)!
    }()
    
    var edit: ((Signal) -> Signal)?
    
    private lazy var DI: Resolver = {
        Assembler([UserAssembly()]).resolver
    }()
    
    
    override init(rootCoordinator: Coordinator? = nil) {
        super.init(rootCoordinator: rootCoordinator)
        presenter = InitializationController.getInstance()
    }
    
    override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        super.startFlow(withWork: work, finishCompletion: finishCompletion)
        
        print(user.isAuth)
        
        // Автоматическая деавторизация для target "SwyzzyNotAuth"
        if ProcessInfo.processInfo.environment["auto_deauth"] == "true" {
            user.authProvider.deauth()
        }
        
        print(user.isAuth)
        
        (self.presenter as? InitializationControllerProtocol)?.initializationDidEnd = {
            // действия на контроллере, которые будут выполнены в конце инициализации
            self.finishFlow()
        }
        // тут могут быть различные операции инициализации
        // вроде загрузки данных из сети
        // при этом можно настроить обмен данными с базовым вью контроллером
        // чтобы отображать процесс выполнения операций

    }

}
