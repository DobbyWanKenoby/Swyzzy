//
//  SwinjectAssemblies.swift
//  Swyzzy
//
//  Created by Vasily Usov on 26.09.2021.
//

import Foundation
import Swinject
import Combine

class BaseAssembly: Assembly {
    func assemble(container: Container) {
        // Объект, описывающий основного издателя (Combine) приложения
        container.register(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher") { _ in
            PassthroughSubject<AppEvents, Never>()
        }.inObjectScope(.container)
    }
}

class AuthProvideAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthProviderProtocol.self) { r in
            BaseFirebaseAuthProvider(resolver: r)
        }.inObjectScope(.container)
    }
}

class UserAssembly: Assembly {
    func assemble(container: Container) {
        container.register(UserProtocol.self) { r in
            let authProvider = r.resolve(AuthProviderProtocol.self)! as AuthProviderProtocol
            return AppUser(authProvider: authProvider, uid: authProvider.uid!)
        }.inObjectScope(.container)
    }
}
