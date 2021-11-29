/*
 HelloCoordinator - координатор приветствия
 Предназначен для отображения инструкции и запроса первичных данных у пользователя
 */

import UIKit
import SwiftCoordinatorsKit
import Swinject
import Firebase
import FirebaseAuth
import Combine

protocol HelloCoordinatorProtocol: BasePresenter, Transmitter {
    init(rootCoordinator: Coordinator, resolver: Resolver)
}

final class HelloCoordinator: BasePresenter, HelloCoordinatorProtocol, Loggable {

    // основной издатель приложения
    private var appPublisher: PassthroughSubject<AppEvents, Never> {
        resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
    }

    var logResolver: Resolver {
        resolver
    }
	private var resolver: Resolver

	// объект-пользователь
	private var user: UserProtocol {
		resolver.resolve(UserProtocol.self)!
	}
    
    private var currentChildViewController: UIViewController? = nil {
        didSet {

            guard let newVC = currentChildViewController else {
                return
            }

            // Если отображается первый экран
            guard let oldVC = oldValue else {
                presenter?.addChild(newVC)
                presenter?.view.addSubview(newVC.view)
                newVC.didMove(toParent: self.presenter)
                return
            }

            oldVC.view.layer.opacity = 1
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn) {
                oldVC.view.layer.opacity = 0
                oldVC.view.frame.origin.x = -UIScreen.main.bounds.width
            } completion: { _ in
                oldVC.view.removeFromSuperview()
                oldVC.removeFromParent()
            }

            presenter?.addChild(newVC)
            newVC.view.frame.origin = CGPoint(x: UIScreen.main.bounds.width, y: 0)
            presenter?.view.addSubview(newVC.view)

            newVC.view.layer.opacity = 0
            UIView.animate(withDuration: 0.3, delay: 0.1) {
                newVC.view.layer.opacity = 1
                newVC.view.frame.origin.x = 0
            } completion: { _ in
                newVC.didMove(toParent: self.presenter)
            }

        }
    }

	var edit: ((Signal) -> Signal)?

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
		presenter = HelloControllerContainer.getInstance()
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        logger.log(.coordinatorStartedFlow, description: String(describing: Self.Type.self))
		super.startFlow(withWork: work, finishCompletion: finishCompletion)
        show(screen: .name)
        
//		(self.presenter as? InitializationControllerProtocol)?.initializationDidEnd = {
//			// действия на контроллере, которые будут выполнены в конце инициализации
//			self.finishFlow()
//		}
	}
    
    private func show(screen: HelloScreen) {
        switch screen {
        case .welcome:
            currentChildViewController = getWelcomeController()
        case .addGift:
            currentChildViewController = getAddGiftController()
        case .lookFeed:
            currentChildViewController = getLookFeedController()
        case .name:
            currentChildViewController = getNameController()
        }
    }

    private func getNameController() -> HelloTextFieldScreen {
        let controller = HelloTextFieldViewController.getInstance()
        controller.configureWith(image: UIImage(named: "HelloScreenWelcome"),
                                 title: L.HelloScreen.nameTitle.localized,
                                 text: L.HelloScreen.nameText.localized,
                                 buttonText: L.Base.save.localized,
                                 textFieldText: "",
                                 textFieldPlaceholder: L.HelloScreen.namePlaceholder.localized)
        controller.actionOnPressButton = {
            guard let name = controller.textField.text, name != "" else {
                let button = AppEvents.ShowEventButton(title: L.Base.ok.localized, style: .cancel) {
                    controller.textField.becomeFirstResponder()
                }
                let alert = AppEvents.ShowEventType.withTitleAndText(title: L.Base.attention.localized, message: L.HelloScreen.youMustEnterName.localized)
                self.appPublisher.send(AppEvents.showEvent(onScreen: controller, type: alert, buttons: [button]))
                return
            }

            controller.button.isEnabled = false

            //self.show(screen: .addGift)
        }
        return controller
    }
    
    private func getWelcomeController() -> HelloInformationScreen {
        let controller = HelloInformationController.getInstance()
        controller.configureWith(image: UIImage(named: "HelloScreenWelcome"),
                                 title: L.HelloScreen.welcomeTitle.localized,
                                 text: L.HelloScreen.welcomeText.localized,
                                 buttonText: L.Base.next.localized)
        controller.actionOnPressButton = {
            self.show(screen: .addGift)
        }
        return controller
    }

    private func getAddGiftController() -> HelloInformationScreen {
        let controller = HelloInformationController.getInstance()
        controller.configureWith(image: UIImage(named: "HelloScreenAddGift"),
                                 title: L.HelloScreen.addGiftTitle.localized,
                                 text: L.HelloScreen.addGiftText.localized,
                                 buttonText: L.Base.next.localized)
        controller.actionOnPressButton = {
            self.show(screen: .lookFeed)
        }
        return controller
    }

    private func getLookFeedController() -> HelloInformationScreen {
        let controller = HelloInformationController.getInstance()
        controller.configureWith(image: UIImage(named: "HelloScreenLookFeed"),
                                 title: L.HelloScreen.lookFeedTitle.localized,
                                 text: L.HelloScreen.lookFeedText.localized,
                                 buttonText: L.Base.next.localized)
        controller.actionOnPressButton = {
            self.show(screen: .welcome)
        }
        return controller
    }

}

enum HelloScreen {
    case welcome
    case addGift
    case lookFeed
    case name
}
