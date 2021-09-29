//
//  SWTextField.swift
//  Swyzzy
//
//  Created by Vasily Usov on 27.09.2021.
//

import UIKit

class SWTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        // базовые установки
        self.layer.backgroundColor = UIColor(named: "TextFieldColor")?.cgColor
        self.layer.borderColor = UIColor(named: "TextFieldBorderColor")?.cgColor
        self.textColor = UIColor(named: "TextFieldTextColor")
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        
        self.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    }

}
