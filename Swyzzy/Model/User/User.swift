//
//  User.swift
//  Swyzzy
//
//  Created by Vasily Usov on 30.11.2021.
//

import Foundation
import Swinject
import Firebase

protocol User: Injectable {
    var needDownloadDataFromExternalStorage: Bool { get set }

    // Уникальный идентификатор
    var uid: String { get set }
    // Номер телефона
    var phone: String { get set }
    // Имя пользователя
    var name: String { get set }

    init(resolver: Resolver)
    // загружает в профиль пользователя данные из внешнего хранилища
    func downloadProfileFromExternalStorage(completion: ((Result<User, Error>) -> Void)?)
    // выйти из учетной записи
    func logout()
}

class FirebaseBasedUser: User {
    var needDownloadDataFromExternalStorage: Bool = true
    var uid: String = ""
    var phone: String = ""
    var name: String = ""
    private var db: Firestore = Firestore.firestore()
    private let resolver: Resolver
    required init(resolver: Resolver) {
        self.resolver = resolver
    }

    func downloadProfileFromExternalStorage(completion: ((Result<User, Error>) -> Void)?) {
        let userDocRef = db.collection("users").document("\(uid)")
        userDocRef.getDocument { (document, error) in
            guard error == nil else {
                completion?(Result.failure(UserError.error(error!.localizedDescription)))
                return
            }
            guard let document = document else {
                completion?(Result.failure(UserError.error(nil)))
                return
            }
            guard let data = document.data(),
               let phone = data["phone"] as? String,
               let name = data["name"] as? String else {
                   completion?(Result.failure(UserError.cantDownloadProfileData))
                   return
            }
            self.phone = phone
            self.name = name
            completion?(Result.success(self))
            }

    }

    func logout() {
        try? Auth.auth().signOut()
    }


}
