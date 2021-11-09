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
    
    private lazy var user: UserProtocol? = {
        resolver.resolve(UserProtocol.self)
    }()

	var edit: ((Signal) -> Signal)?

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
		presenter = InitializationController.getInstance()
		(presenter as! InitializationController).displayType.append(.withActivityIndicator)
		if user == nil {
			(presenter as! InitializationController).displayType.append(.withLogoAnimationTop)
		}
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)

		guard let initController = self.presenter as? InitializationControllerProtocol else {
			return
		}

		initController.startInitializationWork = {
			// TODO: Убрать фейковую паузу
			//sleep(2)
			self.loadDataForAuthUserIfNeed()
			initController.stopInitialization {
				self.finishFlow()
			}
		}

	}

	private func loadDataForAuthUserIfNeed() {
		if user != nil {
            user!.dataNeedSync = false
		}
	}

}
