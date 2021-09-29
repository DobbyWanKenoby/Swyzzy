//
//  Country.swift
//  Swyzzy
//
//  Created by Vasily Usov on 29.09.2021.
//

import Foundation
import UIKit

struct Country {
    
    var name: String
    var phoneCode: String
    var image: UIImage?
    
    init(name: String = "", phoneCode: String = "", image: UIImage? = nil) {
        self.name = name
        self.phoneCode = phoneCode
        self.image = image
    }
}
