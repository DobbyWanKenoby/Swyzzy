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

	// Вспылвающее уведомление
	case showEvent(onScreen: UIViewController, type: ShowEventType, buttons: [ShowEventButton] = [])


	// MARK: Дочерние типы

	// Тип всплывающего уведомления
	enum ShowEventType {
		// Заголовок и текст
		case withTitleAndText(title: String, message: String)
	}

	// Структура описывает кнопку при отправке события showEventMessage
	// Каждая кнопка может содержать собственный текст и реакцию на нажатие
	struct ShowEventButton {
		var title: String
		var style: UIAlertAction.Style
		var handler: (() -> Void)?
	}
}
