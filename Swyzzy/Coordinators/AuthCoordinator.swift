/*
 AuthCoordinator - координатор, обеспечивающий авторизацию пользователя в приложении
 */

// TODO: Автоматический показ экрана ввода кода, если код был отправлен ранее

import UIKit
import SwiftCoordinatorsKit
import Swinject
import Combine

protocol AuthCoordinatorProtocol: BasePresenter, Transmitter {}

final class AuthCoordinator: BasePresenter, AuthCoordinatorProtocol {

	// MARK: - Properties

	// список стран для выбора кода
	private var countries: [Country] = []

	// основной издатель приложения
	private var appPublisher: PassthroughSubject<AppEvents, Never> {
		resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
	}
    
    private var resolver: Resolver

	// MARK: - Others

	var edit: ((Signal) -> Signal)?

	lazy var _presenter: UIViewController? = {
		UINavigationController()
	}()
	override var presenter: UIViewController? {
		get {
			_presenter
		}
		set {
			fatalError("[AuthCoodinator] Setting of presenter is not available")
		}
	}

	init(rootCoordinator: Coordinator, resolver: Resolver) {
		self.resolver = resolver
		super.init(rootCoordinator: rootCoordinator)
	}

	override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
		super.startFlow(withWork: work, finishCompletion: finishCompletion)

		loadingData()

		let authController = getAuthController()
		authController.displayType = .withFadeAnimationExludeLogo
		(presenter as! UINavigationController).viewControllers.append(authController)
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

		// Дейтсвия при отправке СМС
		controller.sendSMSCodeByPhone = { phone in
			// блокируем клавишу отправки
			controller.disableSMS()
            
            // Создаем провайдер авторизации по телефону
            let authProvider = AuthProviderFactory.getPhoneAuthProvider(resolver: self.resolver)
            authProvider.sendSMS(toPhone: phone) { result in
                switch result {
                // в случае успешной отправки СМС
                case .success(_):
                    let codeController = PhoneCodeController()
                    codeController.phone = phone
                    codeController.doAfterCodeDidEnter = { code in
                        // отображаем всплывающее окно
                        self.showLoadingAlert(onScreen: codeController, title: Localization.Base.wait.localized, message: L.AuthPhoneCodeScreen.checkCode.localized, completion: {
                            // пытаемся авторизоваться
                            authProvider.auth(withCode: code) { authResult in
                                switch authResult {
                                case .success(_):
                                    self.disroute(controller: codeController, method: .dismiss, completion: {
                                        let event = AppEvents.userLogin(onController: codeController)
                                        self.appPublisher.send(event)
                                    })
                                case .failure(let authError):
                                    var message: String
                                    if case let AuthError.message(m) = authError {
                                        message = m
                                    } else {
                                        message = Localization.Error.repeatAfterSomeTime.localized
                                    }
                                    self.showAlert(onScreen: codeController, title: Localization.Error.error.localized, message: message, repeatWork: nil)
                                }
                            }
                        })
                    }
                    self.route(from: self.presenter!, to: codeController, method: .presentCard) {
                        controller.enableSMS()
                    }
                // в случае ошибки при отправке смс
                case .failure(let error):
                    controller.enableSMS()

                    var errorMessage = error.localizedDescription
                    if case AuthError.message(let message) = error {
                        errorMessage = message
                    }

                    self.showAlert(onScreen: controller, title: Localization.Error.error.localized, message:errorMessage)
                }
                
            }
		}

		return controller
	}
    
    private func showLoadingAlert(onScreen: UIViewController, title: String, message: String, completion: (() -> Void)?) {
        let alert = AppEvents.ShowEventType.withTitleAndText(title: title, message: message)
        appPublisher.send(AppEvents.showEvent(onScreen: onScreen, type: alert, buttons: [], completion: completion))
    }
    
    private func showAlert(onScreen: UIViewController, title: String, message: String, repeatWork: (()->Void)? = nil) {
        let alert = AppEvents.ShowEventType.withTitleAndText(title: title, message: message)
        var button: AppEvents.ShowEventButton
        if repeatWork != nil {
            button = AppEvents.ShowEventButton(title: Localization.Base.repeatit.localized, style: .cancel, handler: {
                repeatWork?()
            })
        } else {
            button = AppEvents.ShowEventButton(title: Localization.Base.ok.localized, style: .cancel)
        }
        appPublisher.send(AppEvents.showEvent(onScreen: onScreen, type: alert, buttons: [button]))
    }


}
