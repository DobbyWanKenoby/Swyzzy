//
//  StringsEnum.swift
//  Swyzzy
//
//  Created by Vasily Usov on 27.09.2021.
//

import Foundation

/**
 Протокол LocalizationEnumProtocol обеспечивает доступ к свойству localized, которое получает значение из файла Localizable.strings
 */

protocol LocalizationEnumProtocol {
    var localized: String { get }
}

extension LocalizationEnumProtocol where Self: RawRepresentable {
    var localized: String {
        return "\(Self.self)_\(self.rawValue)".localized()
    }
}

// Перечисление с элементами для локализации

enum Localization {
    
    // Общие для приложения
    enum Base: String, LocalizationEnumProtocol {
        case attention
        case ok
        case cancel
    }
    
    // Экран входа
    enum AuthScreen: String, LocalizationEnumProtocol {
        case sendCodeButton
        case aboutPolicy
        case phoneNumber
        case moneyForSMS
        case alertWrongPhoneNumber
    }
    
    // Экран подтверждения СМС
    enum AuthPhoneCodeScreen: String, LocalizationEnumProtocol {
        case title
        case subtitle
        case checkCode
    }
}



