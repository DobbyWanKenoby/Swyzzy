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
    
    /// Объект пользователя
    var user: UserProtocol! { get set }
    
    /// В случае успешного ввода кода
    var doAfterCorrectCodeDidEnter: (() -> Void)? { get set }
}

class PhoneCodeController: UIViewController, PhoneCodeControllerProtocol {
    
    // MARK: Properties

    var phone: String!
    var user: UserProtocol!
    
    // MARK: Callbacks
    
    var doAfterCorrectCodeDidEnter: (() -> Void)? = nil
    
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
        let view = SWCodeField(blocks: 2, elementsInBlock: 3)
        view.doAfterCodeDidEnter = { code in
			let alert = UIAlertController(title: Localization.Base.wait.localized, message: L.AuthPhoneCodeScreen.checkCode.localized, preferredStyle: .alert)
            self.present(alert, animated: true) {
                
                // попытка авторизации
                self.user.authProvider.tryAuthWith(code: self.codeField.code) {
                // в случае успешного ввода КОРРЕКТНОГО кода
                    alert.dismiss(animated: true) {
                        self.doAfterCorrectCodeDidEnter?()
                    }
                // в случае каких-лиюо ошибок
                } errorHandler: { e in
                    var errorMessage = ""
                    
                    // в случае ошибки в коде (или других ошибок, вроде спама)
                    if case AuthError.message(let message) = e {
                        errorMessage = message
                    }
                    
                    alert.dismiss(animated: false) {
                        let errorAlert = UIAlertController(
                            title: Localization.Error.error.localized,
                            message: errorMessage,
                            preferredStyle: .alert)
                        let action = UIAlertAction(title: Localization.Base.ok.localized, style: .cancel, handler: nil)
                        errorAlert.addAction(action)
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }

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
            make.height.equalTo(50)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    

}
