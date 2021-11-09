//
//  SWStorageProvider.swift
//  Swyzzy
//
//  Created by Vasily Usov on 09.11.2021.
//

import Foundation
import Swinject
import Firebase

protocol StorageProviderProtocol {
    init(resolver: Resolver)

    // Синхронизация данных пользователя
    // Автоматически обновляет данные в user и по завершению вызывает completion
    func downloadAndUpdateUserData(completion: ((Error?) -> Void)?)
}

class FirebaseStorageProvider: StorageProviderProtocol, Loggable {
    var logResolver: Resolver {
        resolver
    }
    private var resolver: Resolver
    private var db: Firestore = Firestore.firestore()

    required init(resolver: Resolver) {
        self.resolver = resolver
    }

    func downloadAndUpdateUserData(completion: ((Error?) -> Void)?) {
        var user = resolver.resolve(UserProtocol.self)!
        let userDocRef = db.collection("users").document("\(user.uid)")
        userDocRef.getDocument { (document, error) in
            guard error == nil else {
                completion?(error)
                return
            }
            guard let document = document else {
                completion?(error)
                return
            }
            if !document.exists {
                self.createEntityInStorage(completion: completion)
            } else {
                user.isInExternalStorage = true

                if let data = document.data(),
                   let phone = data["phone"] as? String,
                   let name = data["name"] as? String{
                    user.phone = phone
                    user.name = name
                    // отмечаем данные, как закачанные
                    user.needDownloadDataFromExternalStorage = false
                    user.needEnterPrimaryData = false
                    self.logger.log(.userDataDidDownload)
                } else {
                    self.logger.log(.userDataDontDownload, description: "Need enter primary data maybe")
                }
                user.needDownloadDataFromExternalStorage = false
                completion?(nil)
            }
        }
    }

    private func createEntityInStorage(completion: ((Error?) -> Void)?) {
        var user = resolver.resolve(UserProtocol.self)!
        db.collection("users").document("\(user.uid)").setData([
            "phone": Auth.auth().currentUser?.phoneNumber ?? ""
        ]) { error in
            if let error = error {
                self.logger.log(.userDocumentNotCreated, description: error.localizedDescription)
                completion?(error)
            }
            self.logger.log(.userDocumentCreated)
            user.isInExternalStorage = true
            completion?(error)
        }
    }
}

