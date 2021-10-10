/*
 AuthCoordinator - координатор, обеспечивающий авторизацию пользователя в приложении
 */

import UIKit
import SwiftCoordinatorsKit
import Swinject

protocol AuthCoordinatorProtocol: BasePresenter, Transmitter {}

final class AuthCoordinator: BasePresenter, AuthCoordinatorProtocol {
    
    // MARK: - Properties
    
    // список стран для выбора кода
    var countries: [Country] = []
    // объект-пользователь
    lazy var user: UserProtocol = {
        DI.resolve(UserProtocol.self)!
    }()
    
    var edit: ((Signal) -> Signal)?
    
    private lazy var DI: Resolver = {
        Assembler([UserAssembly()]).resolver
    }()
    
    // используется для доступа к презентеру, как к Navigation Controller
    // свойство - синтаксический сахар
    var navigationPresenter: UINavigationController {
        presenter as! UINavigationController
    }
    
    required init(rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: options)
        presenter = UINavigationController()
    }
    
    required public init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil) {
        fatalError("init(presenter:rootCoordinator:) has not been implemented")
    }
    
    @discardableResult
    public override init(rootCoordinator: Coordinator? = nil) {
        super.init(presenter: nil, rootCoordinator: rootCoordinator, options: [])
        presenter = UINavigationController()
    }
    
    public override init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        fatalError("init(presenter:rootCoordinator:options:) has not been implemented")
    }
    
    override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        super.startFlow(withWork: work, finishCompletion: finishCompletion)
        
        loadingData()
        
        let authController = getAuthController()
        authController.displayType = .withFadeAnimationExludeLogo
        navigationPresenter.viewControllers.append(authController)
    }
    
    // Фоновая загрузка данных, требуемых в ходе работы координатора
    private func loadingData() {
        // загрузка данных о странах и телефонных кодах
        let signal = InternationalizationSignal.getCountriesForSMS
        self.broadcast(signal: signal, withAnswerToReceiver: nil) { answerSignal in
            if case InternationalizationSignal.countries(let countries) = answerSignal {
                self.countries = countries
            }
        }
    }
    
    private func getAuthController() -> AuthControllerProtocol {
        let controller = AuthController.getInstance()
        
        controller.countryImage = UIImage(named: "Russia")
        controller.countryCode = "+7"
        controller.countryPhonePlaceholder = Localization.AuthScreen.phoneNumber.localized
        //controller.user = user
        
        // ------ TEST
        let codeController = PhoneCodeController()
        codeController.phone = "+774747747474"
        self.route(from: self.presenter!, to: codeController, method: .presentCard, completion: nil)
        // ------ TEST
        
        controller.doForCountryChange = {
            let countriesController = CountriesController(style: .insetGrouped)
            countriesController.countries = self.countries
            countriesController.doAfterChoiseCountry = { country in
                controller.countryCode = country.phoneCode
                controller.countryImage = country.image
                countriesController.dismiss(animated: true, completion: nil)
            }
            self.route(from: self.presenter!, to: countriesController, method: .presentCard, completion: nil)
        }
        controller.sendSMSCodeByPhone = { phone in
            self.user.authProvider.sendSMSCode(byPhone: phone) { phone, verificationID, error in
                print(phone, verificationID, error, separator: " - ")
            }
            controller.disableSMS()
            //sleep(3)
            //controller.enableSMS()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 2000)) {
                sleep(1)
                controller.enableSMS()
            }
            
            // показ экрана для ввода кода
            let codeController = PhoneCodeController()
            codeController.phone = phone
            self.route(from: self.presenter!, to: codeController, method: .presentCard, completion: nil)
        }
        
        
        return controller
    }

    
}
