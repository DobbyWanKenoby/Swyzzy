//
//  SwinjectAssemblies.swift
//  Swyzzy
//
//  Created by Vasily Usov on 26.09.2021.
//

import Foundation
import Swinject

class UserAssembly: Assembly {
    func assemble(container: Container) {
        container.register(UserProtocol.self) { _ in SWUser() }
    }
}
