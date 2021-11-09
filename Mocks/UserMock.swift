//
//  UserMock.swift
//  Swyzzy
//
//  Created by Василий Усов on 31.10.2021.
//

/*
 Mock пользователя
 */

import Foundation

class AppUserMock: UserProtocol {
    var uid: String
    var dataNeedSync: Bool = true
    var authProvider: AuthProviderProtocol
    
    required init(authProvider: AuthProviderProtocol, uid: String) {
        self.authProvider = authProvider
        self.uid = uid
    }
}
