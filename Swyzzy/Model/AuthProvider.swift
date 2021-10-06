//
//  AuthProvider.swift
//  Swyzzy
//
//  Created by Василий Усов on 03.10.2021.
//

// Провайдер, который отвечает за авторизацию/деавторизацию пользователя
// Используется в классе User

import Foundation
import Firebase

protocol AuthProviderProtocol {
    
    // MARK: Авторизация
    
    /// авторизован ли пользователь
    var isAuth: Bool { get }
    
    /// деавторизовать пользователя
    func deauth()
    
    /// Отправка СМС с кодом подтверждения на указанный номер
    /// 
    /// - Parameter byPhone: номер, на который отправляется смс
    /// - Parameter completionHandler: замыкание для обработки ответа, принимает три параметра (phoneNumber, verificationID?, error?)
    func sendSMSCode(byPhone: String, completionHandler: ((String, String?,Error?) -> Void)?)
    
    /// Отправка кода подтверждения. Возвращает token
    //func sendConfirmationCode(byPhone: String) -> String
}

class AuthProvider: AuthProviderProtocol {
    
    var isAuth: Bool {
        return false
    }
    
    func deauth() {
        // TODO: Доделать метод
    }
    
    // Авторизация по номеру телефона
    func sendSMSCode(byPhone phoneNumber: String,
                     completionHandler: ((String, String?, Error?) -> Void)? = nil ) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber,
                                                       uiDelegate: nil,
                                                       completion: { verificationID, error in
            completionHandler?(phoneNumber, verificationID, error)
            //print("send to \(phoneNumber)")
            //print("error -\(error)")
            //ыprint("verification - \(verificationID)")
        })
    }
    
    func sendConfirmationCode(byPhone: String) -> String {
        return ""
    }
}
