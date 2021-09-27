//
//  StringExtension.swift
//  Swyzzy
//
//  Created by Vasily Usov on 27.09.2021.
//

import Foundation

extension String {
    // Возвращает локализованную версию строки
    func localized() -> String {
        return NSLocalizedString("\(self)", comment: "")
    }
}
