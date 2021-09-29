/*
 FunctionalCoordinator - координатор, предназначенный для выполнения приложением своих функций
 Запускается после InitializatorCoordinator и отображает интерфейс приложения
 */

import UIKit
import SwiftCoordinatorsKit
import Swinject

protocol FunctionalCoordinatorProtocol: BasePresenter, Transmitter {}

final class FunctionalCoordinator: BasePresenter, FunctionalCoordinatorProtocol {
    
    // MARK: - Properties
    
    var countries: [Country] = []
    
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
        
        backgroundLoadData()
        
        let user = DI.resolve(UserProtocol.self)!
        
        if user.isAuth {
            navigationPresenter.viewControllers.append(getAuthController())
        } else {
            let controller = InitializationController.getInstance()
            controller.view.backgroundColor = .red
            navigationPresenter.viewControllers.append(controller)
        }
    }
    
    // Фоновая загрузка данных, требуемых в ходе работы координатора
    private func backgroundLoadData() {
        DispatchQueue.global(qos: .background).async {
            let signal = InternationalizationSignal.getCountriesForSMS
            self.broadcast(signal: signal, withAnswerToReceiver: nil) { answerSignal in
                if case InternationalizationSignal.countries(let countries) = answerSignal {
                    self.countries = countries
                }
            }
        }
    }
    
    private func getAuthController() -> AuthControllerProtocol {
        let controller = AuthController.getInstance()
        controller.countryImage = UIImage(named: "Russia")
        controller.countryCode = "+ 7"
        controller.countryPhonePlaceholder = Localization.AuthScreen.phoneNumber.localized
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
        
        return controller
    }

    
}
