//
//  PhoneCodeController.swift
//  Swyzzy
//
//  Created by Vasily Usov on 30.09.2021.
//

import UIKit

protocol PhoneCodeControllerProtocol: UIViewController {
    
    /// Номер телефона, на который отправлено СМС с кодом
    var phone: String! { get set }
}

class PhoneCodeController: UIViewController, PhoneCodeControllerProtocol {

    var phone: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    

}
