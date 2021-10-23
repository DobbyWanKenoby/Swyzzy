//
//  ReactiveEventsTube.swift
//  Swyzzy
//
//  Created by Vasily Usov on 23.10.2021.
//

import UIKit


// AppPublisher - основной Издатель (Combine) приложения, передающий информацию о различных событиях внутри приложения

// перечень отслеживаемых/передаваемых событий
enum AppEvents {
	case userLogin(onController: UIViewController)
}
