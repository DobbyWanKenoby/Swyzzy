//
//  Logger.swift
//  Swyzzy
//
//  Created by Vasily Usov on 09.11.2021.
//

import Foundation
import Swinject

enum LogType {
    case console
}

func log(_ type: LogType, message: String, source: Any? = nil) {
    print( "[Info Swyzzy] :", source ?? "" , message )
}

func error(_ type: LogType, message: String, source: Any? = nil) {
    print( "[Error Swyzzy] :", source ?? "" , message )
}



