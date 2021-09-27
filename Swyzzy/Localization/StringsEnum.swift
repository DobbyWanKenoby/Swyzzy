//
//  StringsEnum.swift
//  Swyzzy
//
//  Created by Vasily Usov on 27.09.2021.
//

import Foundation

enum Localization {
    
    // Экран входа
    enum AuthScreen: String {
        case sendCodeButton = "sendCodeButton"
        case aboutPolicy = "aboutPolicy"
        
        var localized: String {
            self.rawValue.localized()
        }
    }
}
