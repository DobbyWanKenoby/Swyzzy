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
    
    // MARK: Properties

    var phone: String!
    
    // MARK: Views
    
    private lazy var headerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerTitle, headerSubtitle])
        view.distribution = .fill
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 10
        return view
    }()
    
    private lazy var headerTitle: UILabel = {
        let title = UILabel()
        title.text = Localization.AuthPhoneCodeScreen.title.localized
        title.font = .systemFont(ofSize: 30, weight: .medium)
        return title
    }()
    
    private lazy var headerSubtitle: UILabel = {
        let title = UILabel()
        title.text = Localization.AuthPhoneCodeScreen.subtitle.localized + " \(phone ?? "")"
        title.numberOfLines = 0
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 14)
        return title
    }()
    
    private lazy var codeField: SWCodeField = {
        let view = SWCodeField()
        view.onCodeEntered = {
            let alert = UIAlertController(title: "", message: Localization.AuthPhoneCodeScreen.checkCode.localized, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: Localization.Base.cancel.localized, style: .cancel) { _ in
                alert.dismiss(animated: true) {
                    
                }
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true) {
                
            }
        }
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.topMargin.equalTo(100)
            make.leadingMargin.trailingMargin.equalTo(40)
        }
        
        self.view.addSubview(codeField)
        codeField.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.leadingMargin.trailingMargin.equalTo(40)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    

}
