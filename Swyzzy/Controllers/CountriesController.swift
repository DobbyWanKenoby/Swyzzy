//
//  CountriesController.swift
//  Swyzzy
//
//  Created by Vasily Usov on 29.09.2021.
//

import UIKit

protocol CountriesControllerProtocol {
    // Массив стран
    var countries: [Country] { get set }
    
    // выполнить при выборе страны
    var doAfterChoiseCountry: ((Country) -> Void)? { get set }
}

class CountriesController: UITableViewController, CountriesControllerProtocol {
    
    // MARK: - Coordinator Input Data
    
    private var _countries: [Country] = []
    var countries: [Country] {
        get {
            return _countries.sorted { a, b in
                a.name < b.name
            }
        }
        set {
            
            _countries = newValue
        }
    }
    
    // MARK: - Coordinator Callbacks

    var doAfterChoiseCountry: ((Country) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
}

// MARK: - Table View

extension CountriesController  {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CountryCell")
        var configuration = cell.defaultContentConfiguration()
        configuration.image = countries[indexPath.row].image
        configuration.text = "\(countries[indexPath.row].name)"
        configuration.secondaryText = "\(countries[indexPath.row].phoneCode)"
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = countries[indexPath.row]
        doAfterChoiseCountry?(country)
    }

}
