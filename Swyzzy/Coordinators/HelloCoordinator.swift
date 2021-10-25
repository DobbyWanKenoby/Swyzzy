//
//  HelloCoordinator.swift
//  Swyzzy
//
//  Created by Vasily Usov on 24.10.2021.
//

import Foundation

/*
 HelloCoordinator - координатор приветствия
 Предназначен для отображения инструкции и запроса первичных данных у пользователя
 */

import UIKit
import SwiftCoordinatorsKit
import Swinject
import Firebase
import FirebaseAuth

protocol HelloCoordinatorProtocol: BasePresenter, Transmitter {}

final class HelloCoordinator: BasePresenter, HelloCoordinatorProtocol {

	private var resolver: Resolver

	// объект-пользователь
	private var user: UserProtocol {
		resolver.resolve(UserProtocol.self)!
	}

	var edit: ((Signal) -> Signal)?

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
		presenter = HelloControllerContainer.getInstance()
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)

//		(self.presenter as? InitializationControllerProtocol)?.initializationDidEnd = {
//			// действия на контроллере, которые будут выполнены в конце инициализации
//			self.finishFlow()
//		}

	}

}
