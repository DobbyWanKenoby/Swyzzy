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

        // Логгер
        container.register(Logger.self) { r in
            let l = Logger(type: .console, resolver: r)
            l.prefix = ""
            return l
        }.inObjectScope(.container)

        // Менеджер настрое
        container.register(SettingsManager.self) { _ in
            UserDefaultsSettingsManager()
        }.inObjectScope(.container)
    }
}

class AuthAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthProviderProtocol.self) { r in
            BaseFirebaseAuthProvider(resolver: r)
        }.inObjectScope(.container)
    }
}

class UserBuilderAssembly: Assembly {

    func assemble(container: Container) {
        container.register(UserBuilder.self) { r in
            FirebaseUserBuilder(resolver: r)
        }
    }
}

class AuthUserAssembly: Assembly {

    private var instance: User

    init(_ user: User) {
        self.instance = user
    }

    func assemble(container: Container) {
        container.register(User.self) { r in
            return self.instance
        }.inObjectScope(.container)
    }

}
//
//
////    func assemble(container: Container) {
////        container.register(UserProtocol.self) { r in
////            let authProvider = r.resolve(AuthProviderProtocol.self)! as AuthProviderProtocol
////            return AppUser(authProvider: authProvider, uid: authProvider.uid!)
////        }.inObjectScope(.container)
////    }
//}

//class StorageAssembly: Assembly {
//    func assemble(container: Container) {
//        container.register(StorageProvider.self) { r in
//            FirebaseStorageProvider(resolver: r)
//        }.inObjectScope(.container)
//    }
//}
