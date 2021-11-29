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
        addConfiguration()
        addShadow()
    }

    private func addConfiguration() {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = UIColor(named: "AccentColor")
        self.configuration = configuration
    }

    private func addShadow() {
        self.layer.shadowRadius = 4
        self.layer.shadowColor = UIColor.blue.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
