//
//  Internationalization.swift
//  Swyzzy
//
//  Created by Vasily Usov on 29.09.2021.
//

import Foundation
import SwiftCoordinatorsKit

// Сигналы, передаваемые между координаторами
// Описывают различные параметры для интернаационализации приложения

enum InternationalizationSignal: Signal {
    
    // Запрашивает список поддерживаем стран и их телефонных кодов
    case getCountriesForSMS
    
    // Список стран
    case countries([Country])
}
