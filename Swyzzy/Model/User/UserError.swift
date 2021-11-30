//
//  UserError.swift
//  Swyzzy
//
//  Created by Vasily Usov on 30.11.2021.
//

import Foundation

enum UserError: Error {
    case cantCreateUser
    case cantDownloadProfileData
    case error(String?)
}
