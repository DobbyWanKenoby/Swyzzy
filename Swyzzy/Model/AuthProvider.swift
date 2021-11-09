////
////  AuthProvider.swift
////  Swyzzy
////
////  Created by Василий Усов on 03.10.2021.
////
//
//// Провайдер, который отвечает за авторизацию/деавторизацию пользователя
//// Используется в классе User
//
//import Foundation
//import Firebase
//import FirebaseAuth
//
//protocol AuthProviderProtocol {
//
//    var fbUser: User? { get }
//
//    // MARK: Авторизация
//
//    /// авторизован ли пользователь
//    var isAuth: Bool { get }
//
//    /// деавторизовать пользователя
//    func deauth()
//
//    /// Отправка СМС с кодом подтверждения на указанный номер
//    ///
//    /// - Parameter byPhone: номер, на который отправляется смс
//    func sendSMSCode(byPhone: String, successHandler: (() -> Void)?, errorHandler: ((Error) -> Void)?)
//
//    /// Отправка кода подтверждения. Возвращает token
//    ///
//    /// - Parameter code: введенный пользователем код
//    func tryAuthWith(code: String, successHandler: (() -> Void)?, errorHandler: ((Error) -> Void)?)
//}
//
//class AuthProvider: AuthProviderProtocol {
//
//    // ID, который возвращает Firebase в процессе авторизации по смс
//    // Не является token, нужен при отправке кода подтверждения
//    private var fbPhoneVerificationID: String? {
//        get {
//            UserDefaults.standard.string(forKey: "firebasePhoneVerificationID")
//        }
//        set {
//            if  ["", nil].contains(newValue) {
//                UserDefaults.standard.removeObject(forKey: "firebasePhoneVerificationID")
//            } else {
//                UserDefaults.standard.set(newValue, forKey: "firebasePhoneVerificationID")
//            }
//        }
//    }
//
//    var fbUser: User? {
//        Auth.auth().currentUser
//    }
//
//    var isAuth: Bool {
//        if fbUser == nil {
//            return false
//        }
//        return !fbUser!.isAnonymous
//    }
//
//    func deauth() {
//        // TODO: Доделать метод
//
//        fbPhoneVerificationID = nil
//        try? Auth.auth().signOut()
//    }
//
//    // Авторизация по номеру телефона
//    func sendSMSCode(byPhone phoneNumber: String, successHandler: (() -> Void)?, errorHandler: ((Error) -> Void)? = nil) {
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber,
//                                                       uiDelegate: nil,
//                                                       completion: { verificationID, error in
//            if let e = error {
//                self.deauth()
//                errorHandler?(AuthError.message(e.localizedDescription))
//                return
//            }
//            self.fbPhoneVerificationID = verificationID
//            successHandler?()
//        })
//    }
//
//    func tryAuthWith(code: String, successHandler: (() -> Void)?, errorHandler: ((Error) -> Void)?) {
//        guard let verificationID = fbPhoneVerificationID else {
//            errorHandler?(AuthError.message(Localization.Error.repeatAfterSomeTime.localized))
//            return
//        }
//        let credential = PhoneAuthProvider.provider().credential(
//            withVerificationID: verificationID,
//            verificationCode: code
//        )
//
//        Auth.auth().signIn(with: credential) { authResult, error in
//            if let error = error {
//                errorHandler?(AuthError.message(error.localizedDescription))
//                return
//            }
//            successHandler?()
//        }
//
//    }
//}
