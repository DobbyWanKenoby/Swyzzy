//
//  SplashViewController.swift
//  Swyzzy
//
//  Created by Vasily Usov on 30.11.2021.
//

import UIKit
import SnapKit

class SplashViewController: UIViewController {

    lazy private var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Title"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy private var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.tintColor = .red
        return view
    }()

    override func loadView() {
        super.loadView()
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalTo(42)
            make.center.equalToSuperview()
        }

        self.view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}
