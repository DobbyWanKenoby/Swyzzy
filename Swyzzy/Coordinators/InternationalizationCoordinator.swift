//
//  InternationalizationCoordinator.swift
//  Swyzzy
//
//  Created by Vasily Usov on 26.09.2021.
//

import Foundation
import SwiftCoordinatorsKit
import UIKit

protocol InternationalizationCoordinatorProtocol: BaseCoordinator, Receiver {}

class InternationalizationCoordinator: BaseCoordinator, InternationalizationCoordinatorProtocol {
	func receive(signal: Signal) -> Signal? {
		switch signal {
		case InternationalizationSignal.getCountriesForSMS:
			return InternationalizationSignal.countries(getCountries())
		default:
			break
		}
		return nil
	}

	// Возвращает список доступных стран
	// Загружает его из файла CountriesPhones.plist
	private func getCountries() -> [Country] {
		var countries: [Country] = []
		guard let url = Bundle.main.url(forResource: "CountriesPhones", withExtension: "plist") else {
			return countries
		}
		let data = try! Data(contentsOf: url)
		let decoder = PropertyListDecoder()
		let sourceData = try! decoder.decode([CountriesPhonesFile].self, from: data)
		sourceData.forEach { item in
			countries.append(Country(name: item.name, phoneCode: item.phoneCode, image: UIImage(named: item.name)))
		}
		return countries
	}
}

// Helper
// Вспомогательный тип, используемый для извлечения данных из файла CountriesPhones.plist

struct CountriesPhonesFile: Codable {
	var name: String
	var phoneCode: String
}
