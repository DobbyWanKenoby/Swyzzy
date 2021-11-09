//
//  SWUserAuthProvider.swift
//  Swyzzy
//
//  Created by Василий Усов on 29.10.2021.
//

/*
 Mock провайдера авторизации
 Данный провайдер сообщает о успешной авторизации пользователя уже на входе в приложение
 */

import Foundation
import Firebase
import FirebaseAuth
import Swinject
import Combine

extension AuthProviderFactory {
    static func getMockAuthProvider(resolver: Resolver) -> MockAuthProvider {
        MockAuthProvider(resolver: resolver)
    }
}

class MockAuthProvider: AuthProviderProtocol {
    var isAuth: Bool {
       return true
    }
    var uid: String? {
        return "testUID123456789"
    }
    internal var resolver: Resolver
    required init(resolver: Resolver) {
        self.resolver = resolver
    }
    func logout() {}
}
