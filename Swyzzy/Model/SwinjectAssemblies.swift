//
//  SwinjectAssemblies.swift
//  Swyzzy
//
//  Created by Vasily Usov on 26.09.2021.
//

import Foundation
import Swinject
import Combine

class MainAssembly: Assembly {

	static var shared = MainAssembly()

//	private static let user: UserProtocol =
//	private static let appPublisher =

	func assemble(container: Container) {
		// Объект, описывающий пользователя
		container.register(UserProtocol.self) { _ in SWUser() }
		// Объект, описывающий основного издателя (Combine) приложения
		container.register(PassthroughSubject<AppEvents, Never>.self) { _ in PassthroughSubject<AppEvents, Never>() }
	}
}
