//
//  User.swift
//  Swyzzy
//
//  Created by Vasily Usov on 26.09.2021.
//

import Foundation
import FirebaseAuth

protocol UserProtocol {
    var isAuth: Bool { get set }
    var authProvider: AuthProviderProtocol { get set }
}

protocol AuthProviderProtocol {
    // MARK: Авторизация по номеру телефона
    
    // Отправка СМС с кодом
    func sendSMSCode(byPhone: String)
}

class User: UserProtocol {
    var authProvider: AuthProviderProtocol = AuthProvider()
    var isAuth: Bool = true
    
    
}

class AuthProvider: AuthProviderProtocol {
    
    // Авторизация по номеру телефона
    func sendSMSCode(byPhone phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            print("send to \(phoneNumber)")
            print("error -\(error)")
            print("verification - \(verificationID)")
        }
    }
}
