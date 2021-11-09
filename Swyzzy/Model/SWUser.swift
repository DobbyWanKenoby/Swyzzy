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
    var uid: String { get set }
    /// Номер телефона
    var phone: String { get set }
    /// Имя
    var name: String { get set }

    /// Провайдер авторизации
    var authProvider: AuthProviderProtocol { get set }

    /// Флаг, существует ли в базе запись о пользвоателе
    /// Используется для того, чтобы показать экран ввода первичных данных
    var isInExternalStorage: Bool { get set }

    /// Необходимость синхронизации данных
    /// true
    ///     - сразу после авторизации
    ///     - после загрузки приложения
    /// false после проведения авторизации
    var needDownloadDataFromExternalStorage: Bool { get set }

    /// Указывает на необходимость ввода первичных данных
    /// Если false, значит на сервере нет каких-либо данных о пользователе (имени, номера телефона)
    var needEnterPrimaryData: Bool { get set }
    
    /// Инициализатор
    init(authProvider: AuthProviderProtocol, uid: String)
    
    /// Завершение сеанса, выход из учетной записи
    func logout()

}

extension UserProtocol {
    func logout() {
        authProvider.logout()
    }
}


// Стандартный пользователь, работа которого основана на FireBase
class AppUser: UserProtocol {
    var authProvider: AuthProviderProtocol
    var uid: String
    var phone: String = ""
    var name: String = ""
    var needDownloadDataFromExternalStorage: Bool = true
    var needEnterPrimaryData: Bool = true
    var isInExternalStorage: Bool = false
    
    required init(authProvider: AuthProviderProtocol, uid: String) {
        self.authProvider = authProvider
        self.uid = uid
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
