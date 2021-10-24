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
	var resolver: Resolver { get set }
}

final class AlertCoordinator: BaseCoordinator, AlertCoordinatorProtocol {

	var resolver: Resolver

	// основной издатель приложения
	private var appPublisher: PassthroughSubject<AppEvents, Never> {
		resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
	}

	// объект-пользователь
	private var user: UserProtocol {
		resolver.resolve(UserProtocol.self)!
	}

	var appEventsSubscriber: AnyCancellable!

	var edit: ((Signal) -> Signal)?

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
	}

	// Создание подписчиков
	private func createSubscribers() {
		appEventsSubscriber = appPublisher.sink(receiveValue: { event in
			switch event {
			case .showEvent(onScreen: let sourceController, title: let title, message: let message, buttons: let buttons):
				self.showAlert(onScreen: sourceController, title: title, message: message, buttons: buttons)
			default:
				return
			}
		})
	}

	// Отображает всплывающее окно с сообщением
	private func showAlert(onScreen: UIViewController, title: String, message: String, buttons: [AppEventAlertButton]) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		for b in buttons {
			let action = UIAlertAction(title: b.title, style: b.style, handler: { _ in
				b.handler?()
			})
			alert.addAction(action)
		}
		onScreen.present(alert, animated: true, completion: nil)
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)
		createSubscribers()
	}

}

