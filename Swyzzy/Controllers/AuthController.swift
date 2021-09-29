/*
 Контроллер авторизации в приложении
 */

import UIKit
import SnapKit

protocol AuthControllerProtocol where Self: UIViewController {
    /// Флаг страны
    var countryImage: UIImage? { get set }
    /// Код страны
    var countryCode: String? { get set }
    /// Шаблон заполнения номера телефона
    var countryPhoneTemplate: String? { get set }
    /// Заменитель текста для текстового поля с номером телефона
    var countryPhonePlaceholder: String? { get set }
    
    /// Действие по нажатию на кнопку с кодом страны
    var doForCountryChange: (() -> Void)? { get set }
}

class AuthController: UIViewController, AuthControllerProtocol {
    
    // MARK: - Coordinator Input Data
    
    var countryImage: UIImage? {
        didSet {
            let handler: UIButton.ConfigurationUpdateHandler = { button in
                button.configuration?.image = self.countryImage
            }
            phoneCodeView.configurationUpdateHandler = handler
        }
    }
    
    var countryCode: String? {
        didSet {
            phoneCodeView.setTitle(self.countryCode, for: .normal)
        }
    }
    
    var countryPhoneTemplate: String?
    
    var countryPhonePlaceholder: String?
    
    // MARK: - Coordinator Callbacks
    
    var doForCountryChange: (() -> Void)? = nil

    // MARK: - View
    
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
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        stack.distribution = .fill
        stack.spacing = 20
        return stack
    }()
    
//    lazy private var phoneCodeView: PhoneCodeView = {
//        let view = PhoneCodeView(image: UIImage(named: "Russia") ?? UIImage(), text: "+7")
//        return view
//    }()
    
    lazy private var phoneCodeView: UIButton = {
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = countryImage
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseBackgroundColor = UIColor(named: "TextFieldColor")
        configuration.baseForegroundColor = UIColor(named: "TextColor")
        
        let button = UIButton(type: .system)
        button.configuration = configuration
        button.setTitle(countryCode, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "TextFieldBorderColor")?.cgColor
        button.layer.cornerRadius = 8
        
        button.addAction(UIAction(handler: { _ in
            self.doForCountryChange?()
        }), for: .touchUpInside)
        
        return button
    }()
    
    lazy private var phoneNumberTextField: SWTextField = {
        let textfield = SWTextField()
        textfield.placeholder = countryPhonePlaceholder
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
