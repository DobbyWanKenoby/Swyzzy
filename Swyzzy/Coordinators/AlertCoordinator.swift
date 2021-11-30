//
//  AlertCoordinator.swift
//  Swyzzy
//
//  Created by Vasily Usov on 24.10.2021.
//

import UIKit
import SwiftCoordinatorsKit
import Swinject
import Combine

/*
 AlertCoordinator отображает всплывающие уведомления.

 Он слушает издателя AppPublisher и реагирует на соответсвующие события
 */

protocol AlertCoordinatorProtocol: BaseCoordinator {
    init(rootCoordinator: Coordinator, resolver: Resolver)
}

final class AlertCoordinator: BaseCoordinator, AlertCoordinatorProtocol {
    var logResolver: Resolver {
        resolver
    }
	private var resolver: Resolver

	// основной издатель приложения
	private var appPublisher: PassthroughSubject<AppEvents, Never> {
		resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
	}

	var appEventsSubscriber: AnyCancellable!

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
	}
    
    private var previousAlertController: UIAlertController?
    
	// Создание подписчиков
	private func createSubscribers() {
		appEventsSubscriber = appPublisher.sink(receiveValue: { event in
			switch event {
            case .showEvent(onScreen: let sourceController, type: let eventType, buttons: let buttons, completion: let completion):
				if case .withTitleAndText(let title, let message) = eventType {
					DispatchQueue.main.async {
						self.showAlert(onScreen: sourceController, title: title, message: message, buttons: buttons, completion: completion)
					}
				}
			default:
				return
			}
		})
	}

	// Отображает всплывающее окно с сообщением
    /* TODO: Потенциально может быть проблема с отображение новых окон, если старое еще отображается.
     Нужно предусмотреть, чтобы старое окно на onScreen скрывалось, прежде, чем новое отобразится
     Текущая реализация не имеет привязки окна-источник к отображаемого окну.
     */
    private func showAlert(onScreen: UIViewController, title: String, message: String, buttons: [AppEvents.ShowEventButton], completion: (()->Void)?) {
        self.previousAlertController?.dismiss(animated: true, completion: nil)
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		for b in buttons {
			let action = UIAlertAction(title: b.title, style: b.style, handler: { _ in
				b.handler?()
			})
			alert.addAction(action)
		}
        previousAlertController = alert
		onScreen.present(alert, animated: true, completion: completion)
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)
		createSubscribers()
	}

}

