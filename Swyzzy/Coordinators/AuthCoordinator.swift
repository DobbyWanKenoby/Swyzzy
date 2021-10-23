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

	// MARK: - Input

	var resolver: Resolver {
		didSet {
			print(444444)
		}
	}

	// MARK: - Properties

	// список стран для выбора кода
	private var countries: [Country] = []

	// объект-пользователь
	private var user: UserProtocol {
		return resolver.resolve(UserProtocol.self)!
	}

	// основной издатель приложения
	private var appPublisher: PassthroughSubject<AppEvents, Never> {
		resolver.resolve(PassthroughSubject<AppEvents, Never>.self, name: "AppPublisher")!
	}

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

			// отправляем СМС
			self.user.authProvider.sendSMSCode(byPhone: phone) {

				// в случае успешной отправки СМС

				let codeController = PhoneCodeController()
				codeController.phone = phone
				codeController.user = self.user
				codeController.doAfterCorrectCodeDidEnter = {

					let event = AppEvents.userLogin(onController: codeController)
					self.appPublisher.send(event)

					//let functionalCoordinator = FunctionalCoordinator(rootCoordinator: self)
					//self.route(from: codeController, to: functionalCoordinator.presenter!, method: .presentFullScreen) {}
					//functionalCoordinator.startFlow()
				}
				self.route(from: self.presenter!, to: codeController, method: .presentCard) {
					controller.enableSMS()
				}

				// в случае ошибки при отправке
			} errorHandler: { e in
				controller.enableSMS()

				var errorMessage = ""
				if case AuthError.message(let message) = e {
					errorMessage = message
				}

				let errorAlert = UIAlertController(
					title: Localization.Error.error.localized,
					message: errorMessage,
					preferredStyle: .alert)
				let action = UIAlertAction(title: Localization.Base.ok.localized, style: .cancel, handler: nil)
				errorAlert.addAction(action)
				controller.present(errorAlert, animated: true, completion: nil)
			}
		}

		return controller
	}


}
