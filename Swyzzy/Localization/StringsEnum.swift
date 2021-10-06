//
//  StringsEnum.swift
//  Swyzzy
//
//  Created by Vasily Usov on 27.09.2021.
//

import Foundation

enum Localization {
    
    // Общие для приложения
    enum Base: String {
        case attention
        case ok
        
        var localized: String {
            return "Base_\(self.rawValue)".localized()
        }
    }
    
    // Экран входа
    enum AuthScreen: String {
        case sendCodeButton
        case aboutPolicy
        case phoneNumber
        case moneyForSMS
        case alertWrongPhoneNumber
        
        
        var localized: String {
            //self.rawValue.localized()
            return "AuthScreen_\(self.rawValue)".localized()
        }
    }
}
