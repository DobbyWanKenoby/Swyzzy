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

	private var resolver: Resolver
    
    // объект-пользователь
	private var user: UserProtocol {
        resolver.resolve(UserProtocol.self)!
    }
    
    var edit: ((Signal) -> Signal)?

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
		presenter = InitializationController.getInstance()
		(presenter as! InitializationController).displayType.append(.withActivityIndicator)
		if !user.isAuth {
			(presenter as! InitializationController).displayType.append(.withLogoAnimationTop)
		}
	}
    
    override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        super.startFlow(withWork: work, finishCompletion: finishCompletion)
        
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
