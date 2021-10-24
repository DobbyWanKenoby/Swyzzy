//
//  ReactiveEventsTube.swift
//  Swyzzy
//
//  Created by Vasily Usov on 23.10.2021.
//

import UIKit


// AppPublisher - основной Издатель (Combine) приложения, передающий информацию о различных событиях внутри приложения

enum AppEvents {
	// пользователь залогинился
	case userLogin(onController: UIViewController)

	// нет связи с сетью
	//case networkDiconnected(onController: UIViewController)

	// Информация о некотором осбытии, которое необходимо отобразить
	case showEvent(onScreen: UIViewController, title: String, message: String, buttons: [AppEventAlertButton] = [])
}

// Структура описывает кнопку при отправке события showEventMessage
// Каждая кнопка может содержать собственный текст и реакцию на нажатие
struct AppEventAlertButton {
	var title: String
	var style: UIAlertAction.Style
	var handler: (() -> Void)?
}
