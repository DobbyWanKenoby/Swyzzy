/*
 Контроллер авторизации в приложении
 */

import UIKit
import SnapKit

protocol AuthControllerProtocol where Self: UIViewController {
    //var countryImage: UIImage { get set }
    //var countryCode: String { get set }
    //var countryPhoneTemplate: String { get set }
    //var countryPhonePlaceholder: String { get set }
}

class AuthController: UIViewController, AuthControllerProtocol {
    
    lazy private var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    lazy private var footerLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.AuthScreen.aboutPolicy.localized
        label.font = label.font.withSize(11)
        label.textAlignment = .center
        label.textColor = UIColor(named: "TextColor")
        label.numberOfLines = 0
        return label
    }()
    
    lazy private var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Title"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy private var phoneBlockStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [phoneNumberStackView, sendCodeButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    
    lazy private var sendCodeButton: SWButton = {
        let button = SWButton(frame: CGRect.zero)
        button.setTitle(Localization.AuthScreen.sendCodeButton.localized, for: .normal)
        return button
    }()
    
    lazy private var phoneNumberStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [phoneCodeView, phoneNumberTextField])
        phoneCodeView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        stack.distribution = .fill
        stack.spacing = 20
        return stack
    }()
    
    lazy private var phoneCodeView: PhoneCodeView = {
        let view = PhoneCodeView(image: UIImage(named: "Russia") ?? UIImage(), text: "+7")
        return view
    }()
    
    lazy private var phoneNumberTextField: SWTextField = {
        let textfield = SWTextField()
        textfield.keyboardType = .phonePad
        return textfield
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.view.addSubview(phoneBlockStackView)
        phoneBlockStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.trailing.equalTo(-30)
        }
        
        self.view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width - 180)
            make.top.equalTo(130)
            make.trailing.equalTo(-90)
        }
        
        self.view.addSubview(footerLabel)
        footerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-60)
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
        }
    
    }
    
}
