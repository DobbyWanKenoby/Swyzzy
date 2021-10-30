//
//  User.swift
//  Swyzzy
//
//  Created by Vasily Usov on 26.09.2021.
//

// Класс описывает пользователя

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol UserProtocol {
    /// Уникальный идентификатор
    var uid: String { get }
    
    /// Флаг указывает на то, что необходимо произвести обновление данных (синхронизация с сервером)
    var dataNeedSync: Bool { get set }
    
    init(authProvider: AuthProviderProtocol, uid: String)
    
    /// Завершение сеанса, выход из учетной записи
    func logout()
}

class AppUser: UserProtocol {
    
    /// Провайдер авторизации
    private var authProvider: AuthProviderProtocol
    var uid: String
    var dataNeedSync: Bool = true
    
    required init(authProvider: AuthProviderProtocol, uid: String) {
        self.authProvider = authProvider
        self.uid = uid
    }
    
    func logout() {
        authProvider.logout()
    }
}



//protocol UserProtocol {
//
//	// MARK: Авторизация
//
//	/// Провайдер для работы с авторизацией
//	var authProvider: AuthProviderProtocol { get set }
//	/// Авторизован ли пользователь
//	var isAuth: Bool { get }
//
//	/// firebase-пользователь
//	var fb: User? { get }
//
//	/// Указывает на то, загрузились ли данные после авторизации/входа пользователя
//	var dataDidUpdate: Bool { get set }
//
//	/// Деавторизовать пользователя
//	func deauth()
//}

//class SWUser: UserProtocol {
//
//	var fb: User? {
//		Auth.auth().currentUser
//	}
//
//	var authProvider: AuthProviderProtocol = AuthProvider()
//	var isAuth: Bool {
//		authProvider.isAuth
//	}
//
//	var dataDidUpdate: Bool = false
//
//	func deauth() {
//		authProvider.deauth()
//	}
//
//}
