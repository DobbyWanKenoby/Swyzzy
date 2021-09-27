//
//  User.swift
//  Swyzzy
//
//  Created by Vasily Usov on 26.09.2021.
//

import Foundation

protocol UserProtocol {
    var isAuth: Bool { get set }
}

class User: UserProtocol {
    var isAuth: Bool = true
}
