//
//  SWUserAuthProvider.swift
//  Swyzzy
//
//  Created by Василий Усов on 29.10.2021.
//

import Foundation
import Firebase
import FirebaseAuth
import Swinject
import Combine

// MARK: - Фабрика провайдера авторизации

class AuthProviderFactory {
    // Возвращает провайдер авторизации по телефону
    // На вход принимает Swinject Resolver, который предоставляет тип для пользователя
    static func getPhoneAuthProvider(resolver: Resolver) -> PhoneAuthProvider {
        PhoneAuthProvider(resolver: resolver)
    }
    static func getBaseAuthProvider(resolver: Resolver) -> BaseFirebaseAuthProvider {
        BaseFirebaseAuthProvider(resolver: resolver)
    }
}

protocol AuthProviderProtocol {
    init(resolver: Resolver)
    func logout()
    var isAuth: Bool { get }
    var uid: String? { get }
}

// Используется для работы с авторизацией, когда нет конкретного способа авторизации
// Например, когда пользователь уже вошел и заново заходит в приложение
// В этом случае впринципе пофигу, какой у него способ авторизации был ранее
// Так же используется, как базовый класс для других провайдеров
class BaseFirebaseAuthProvider: AuthProviderProtocol {
    var isAuth: Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }
        return !user.isAnonymous
    }
    var uid: String? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return user.uid
    }
    internal var resolver: Resolver
    required init(resolver: Resolver) {
        self.resolver = resolver
    }
    func logout() {
        try? Auth.auth().signOut()
    }
}

// MARK: - Провайдера авторизации через телефонный номер

protocol PhoneAuthProviderProtocol: BaseFirebaseAuthProvider {
    func sendSMS(toPhone: String, completion:  ((Result<AuthVerificationID, AuthError>) -> Void)?)
    func auth(withCode: String, completion: ((Result<Any?, AuthError>) -> Void)?)
}

class PhoneAuthProvider: BaseFirebaseAuthProvider, PhoneAuthProviderProtocol {
    
    private var firebaseUser: User? {
        Auth.auth().currentUser
    }
    
    // ID, который возвращает Firebase в процессе авторизации по смс
    // Не является token, нужен при отправке кода подтверждения
    private var verificationID: AuthVerificationID?
    
    func sendSMS(toPhone phoneNumber: String, completion: ((Result<AuthVerificationID, AuthError>) -> Void)?) {
        FirebaseAuth.PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber,
                                                       uiDelegate: nil,
                                                       completion: { verificationID, error in
            if let error = error {
                completion?(.failure(AuthError.message(error.localizedDescription)))
                return
            }
            
            guard let id = verificationID else {
                completion?(.failure(AuthError.haveNotCredentials))
                return
            }
            
            self.verificationID = id
            completion?(.success(id))
        })
    }
    
    func auth(withCode code: String, completion: ((Result<Any?, AuthError>) -> Void)?) {
        guard let id = verificationID else {
            completion?(.failure(AuthError.haveNotCredentials))
            return
        }
        let credential = FirebaseAuth.PhoneAuthProvider.provider().credential(
            withVerificationID: id,
            verificationCode: code
        )
        Auth.auth().signIn(with: credential) { [self] authResult, error in
            if let error = error {
                completion?(.failure(AuthError.message(error.localizedDescription)))
                return
            }
            
            guard self.firebaseUser != nil else {
                completion?(.failure(AuthError.haveNotCredentials))
                return
            }
            
            completion?(.success(nil))
        }
    }
}

// Тип используется в методе sendSMS
typealias AuthVerificationID = String
