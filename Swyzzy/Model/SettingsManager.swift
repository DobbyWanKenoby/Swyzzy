//
//  SettingsManager.swift
//  Swyzzy
//
//  Created by Vasily Usov on 29.11.2021.
//

import UIKit

protocol SettingsManager: AnyObject {
    // необходимо ли показывать экран знакомства для обучени и сбора первичных данных
    var needShowHelloFlow: Bool { get set }
    // необходимо обновить данные пользователя
    var needUpdateUserDataFromServer: Bool { get set }
}

class UserDefaultsSettingsManager: SettingsManager, Injectable {
    var needShowHelloFlow: Bool {
        get {
            guard let value = UserDefaults.standard.string(forKey: "needShowHelloFlow"), value != "" else {
                self.needShowHelloFlow = true
                return true
            }
            return UserDefaults.standard.bool(forKey: "needShowHelloFlow")

        }
        set {
            UserDefaults.standard.set(newValue, forKey: "needShowHelloFlow")
        }
    }

    var needUpdateUserDataFromServer: Bool {
        get {
            guard let value = UserDefaults.standard.string(forKey: "needUpdateUserDataFromServer"), value != "" else {
                self.needUpdateUserDataFromServer = true
                return true
            }
            return UserDefaults.standard.bool(forKey: "needUpdateUserDataFromServer")

        }
        set {
            UserDefaults.standard.set(newValue, forKey: "needUpdateUserDataFromServer")
        }
    }
}
