/*
 Контроллер авторизации в приложении
 */

import UIKit
import SnapKit

protocol AuthControllerProtocol: UIViewController {
    /// Флаг страны
    var countryImage: UIImage? { get set }
    /// Код страны
    var countryCode: String? { get set }
    /// Шаблон заполнения номера телефона
    var countryPhoneTemplate: String? { get set }
    /// Заменитель текста для текстового поля с номером телефона
    var countryPhonePlaceholder: String? { get set }
    
    /// Способ появления
    var displayType: AuthControllerDisplayType { get set }
    
    /// объект пользователя
    //var user: UserProtocol! { get set }
    
    /// Действие по нажатию на кнопку с кодом страны
    var doForCountryChange: (() -> Void)? { get set }
    
    /// Дествие по нажатию на кнопку отправки кода
    var sendSMSCodeByPhone: ((String) -> Void)? { get set }
    
    /// Запрещает отправку смс, блокирует кнопки
    func disableSMS()
    func enableSMS()
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
            phoneCodeView.setTitle("\(self.countryCode ?? "") ▼", for: .normal)
        }
    }
    var countryPhoneTemplate: String?
    var countryPhonePlaceholder: String?
    //var user: UserProtocol!
    
    var displayType: AuthControllerDisplayType = .simple
    
    // MARK: - Coordinator Callbacks
    
    var doForCountryChange: (() -> Void)? = nil
    var sendSMSCodeByPhone: ((String) -> Void)? = nil

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
        
        let handler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
            case .disabled:
                button.configuration?.title = ""
                button.configuration?.showsActivityIndicator = true
                button.configuration?.activityIndicatorColorTransformer = UIConfigurationColorTransformer({ _ in
                    return .systemGray
                })
            default:
                button.configuration?.title = Localization.AuthScreen.sendCodeButton.localized
                button.configuration?.showsActivityIndicator = false
            }
        }
        
        button.configurationUpdateHandler = handler
        
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
    
    lazy private var phoneCodeView: UIButton = {
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = countryImage
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseBackgroundColor = UIColor(named: "TextFieldColor")
        configuration.baseForegroundColor = UIColor(named: "TextColor")
        
        let button = UIButton(type: .system)
        button.configuration = configuration
        //button.setTitle("\(String(describing: countryCode)) ▼", for: .normal)
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
    
    lazy private var moneyAttentionsLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.AuthScreen.moneyForSMS.localized
        label.font = label.font.withSize(11)
        label.textAlignment = .center
        label.textColor = UIColor(named: "TextColor")
        label.numberOfLines = 0
        return label
    }()
    
    override func loadView() {
        super.loadView()
        
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
        
        self.view.addSubview(moneyAttentionsLabel)
        moneyAttentionsLabel.snp.makeConstraints { make in
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.topMargin.equalTo(self.phoneBlockStackView.snp.bottom).offset(20)
        }
        
        self.view.addSubview(footerLabel)
        footerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-60)
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
        }
        
        if displayType == .withFadeAnimationExludeLogo {
            self.view.alpha = 0
            phoneBlockStackView.alpha = 0
            moneyAttentionsLabel.alpha = 0
            footerLabel.alpha = 0
        }
        
        addActionToSendButton()
    }
    
    private func addActionToSendButton() {
        sendCodeButton.addAction(UIAction(handler: { _ in
            let phone = "\(self.countryCode ?? "")\(self.phoneNumberTextField.text ?? "")"
            
            do {
                try self.checkPhoneNumber()
                self.sendSMSCodeByPhone?(phone)
            } catch AuthError.phoneFieldIsEmpty {
                self.showAlertWhenPhoneTextFieldIsEmpty()
            } catch {}
            
        }), for: .touchUpInside)
    }
    
    private func showAlertWhenPhoneTextFieldIsEmpty() {
        let alert = UIAlertController(title: Localization.Base.attention.localized, message: Localization.AuthScreen.alertWrongPhoneNumber.localized, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: Localization.Base.ok.localized, style: .default) { _ in
            self.phoneNumberTextField.becomeFirstResponder()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if displayType == .withFadeAnimationExludeLogo {
            self.view.alpha = 1
            UIView.animate(withDuration: 0.3) {
                self.phoneBlockStackView.alpha = 1
                self.moneyAttentionsLabel.alpha = 1
                self.footerLabel.alpha = 1
            }
        }

    }
    
    // MARK: - Logic
    
    func disableSMS() {
        sendCodeButton.isEnabled = false
    }
    func enableSMS() {
        sendCodeButton.isEnabled = true
    }
}

// MARK: - Проверка номера телефона перед отправкой

extension AuthController {
    
    private func checkPhoneNumber() throws -> Void {
        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.isEmpty == false else {
            throw AuthError.phoneFieldIsEmpty
        }
    }
}

/// Тип отображения сцены
enum AuthControllerDisplayType {
    // все элементы сразу видны
    case simple
    // плавное появление (alpha = 1) всех элементов кроме логотипа
    case withFadeAnimationExludeLogo
}
