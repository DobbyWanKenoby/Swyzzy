import Foundation
import Swinject
import Firebase

protocol UserBuilder {
    init(resolver: Resolver)
    // создает пользователя, если это возможно
    // пользователя возможно создать после авторизации
    // пользователь должен быть полностью настроенным, со всеми полями и данными
    func createUserIfCan(completion: ((Result<User, Error>) -> Void)?)
}

class FirebaseUserBuilder: UserBuilder, Injectable {
    private var db: Firestore = Firestore.firestore()
    private var resolver: Resolver
    required init(resolver: Resolver) {
        self.resolver = resolver
    }

    func createUserIfCan(completion: ((Result<User, Error>) -> Void)?) {
        log(.console, message: "UserBuilder try create user", source: self)
        guard let firebaseUser = Auth.auth().currentUser else {
            completion?(Result.failure(UserError.cantCreateUser))
            return
        }
        if firebaseUser.isAnonymous {
            completion?(Result.failure(UserError.cantCreateUser))
        } else {
            getUserFromFirebase(firebaseUser: firebaseUser, completion: completion)
        }
    }

    private func getUserFromFirebase(firebaseUser: FirebaseAuth.User, completion: ((Result<User, Error>) -> Void)?) {
        let userDocRef = db.collection("users").document("\(firebaseUser.uid)")
        userDocRef.getDocument { (document, error) in
            guard error == nil else {
                completion?(Result.failure(UserError.error(error!.localizedDescription)))
                return
            }
            guard let document = document else {
                completion?(Result.failure(UserError.error(nil)))
                return
            }
            if !document.exists {
                self.createEntityInStorage(firebaseUser: firebaseUser, completion: completion)
            } else {
                var user = self.getUserTemplateInstance()
                user.uid = firebaseUser.uid
                user.downloadProfileFromExternalStorage(completion: completion)
            }
        }
    }

    private func createEntityInStorage(firebaseUser: Firebase.User, completion: ((Result<User, Error>) -> Void)?) {
        var user = getUserTemplateInstance()
        db.collection("users").document("\(firebaseUser.uid)").setData([
            "phone": Auth.auth().currentUser?.phoneNumber ?? "",
            "name": "",
            "birthsday": ""
        ]) { error in
            if let error = error {
                completion?(Result.failure(error))
            }
            user.uid = firebaseUser.uid
            user.downloadProfileFromExternalStorage(completion: completion)
        }
    }

    private func getUserTemplateInstance() -> User {
        return FirebaseBasedUser(resolver: resolver)
    }
}
