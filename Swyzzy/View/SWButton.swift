//
//  SWButton.swift
//  Swyzzy
//
//  Created by Vasily Usov on 27.09.2021.
//

import UIKit

class SWButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = UIColor(named: "AccentColor")
        self.configuration = configuration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
