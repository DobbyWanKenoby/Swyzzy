//
//  User.swift
//  Swyzzy
//
//  Created by Vasily Usov on 26.09.2021.
//

// Класс описывает пользователя

import Foundation
import FirebaseAuth

protocol UserProtocol {

	// MARK: Авторизация

	/// Провайдер для работы с авторизацией
	var authProvider: AuthProviderProtocol { get set }
	/// Авторизован ли пользователь
	var isAuth: Bool { get }

	/// firebase-пользователь
	var fb: User? { get }

	/// Деавторизовать пользователя
	func deauth()

}

class SWUser: UserProtocol {

	init() {
		print(12313)
	}

	var fb: User? {
		Auth.auth().currentUser
	}
	
	var authProvider: AuthProviderProtocol = AuthProvider()
	var isAuth: Bool {
		authProvider.isAuth
	}

	func deauth() {
		authProvider.deauth()
	}

}
