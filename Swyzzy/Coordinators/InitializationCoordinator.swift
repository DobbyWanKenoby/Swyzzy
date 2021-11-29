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
import Combine

protocol InitializatorCoordinatorProtocol: BasePresenter, Transmitter {}

final class InitializatorCoordinator: BasePresenter, InitializatorCoordinatorProtocol, Loggable {

    var logResolver: Resolver {
        resolver
    }
	private var resolver: Resolver
    
    private lazy var user: UserProtocol? = {
        resolver.resolve(UserProtocol.self)
    }()

    // Хелпер для доступа к презентеру
    // Сразу возвращает значение требуемого типа
    private var controller: InitializationControllerProtocol {
        presenter as! InitializationControllerProtocol
    }

    // основной издатель приложения
    private var appPublisher: PassthroughSubject<AppEvents, Never> {
        resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
    }

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
        logger.log(.coordinatorStartedFlow, description: String(describing: Self.Type.self))
		super.startFlow(withWork: work, finishCompletion: finishCompletion)

        controller.startInitializationWork = {
			// TODO: Убрать фейковую паузу
			//sleep(2)

            // Если пользователь авторизован
            if self.user != nil {
                self.loadDataForAuthUser()

            // Если не авторизован
            } else {
                self.finish()
            }
		}
	}

	private func loadDataForAuthUser() {
        guard let user = user else {
            finish()
            return
        }
        if user.needDownloadDataFromExternalStorage {
            let storageProvider = resolver.resolve(StorageProvider.self)!
            storageProvider.downloadAndUpdateUserData(completion: { error in

                // Если пришла ошибка
                if let error = error {
                    self.sendErrorMessage(error.localizedDescription) {
                        self.loadDataForAuthUser()
                    }
                } else {
                    self.finish()
                }
            })
        } else {
            finish()
        }
	}

    private func sendErrorMessage(_ text: String, closure: (()->Void)?) {
        let alert = AppEvents.ShowEventType.withTitleAndText(title: Localization.Error.error.localized, message: text)
        let button = AppEvents.ShowEventButton(title: Localization.Base.repeatit.localized, style: .cancel, handler: {
            closure?()
        })
        appPublisher.send(AppEvents.showEvent(onScreen: self.presenter!, type: alert, buttons: [button]))
    }

    private func finish() {
        controller.stopInitialization {
            self.finishFlow()
        }
    }

}
