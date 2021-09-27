/*
 Контроллер авторизации в приложении
 */

import UIKit
import SnapKit

protocol AuthControllerProtocol where Self: UIViewController {

}

class AuthController: UIViewController, AuthControllerProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        
        let phoneCodeView = PhoneCodeView()
        phoneCodeView.backgroundColor = .red
        self.view.addSubview(phoneCodeView)
        phoneCodeView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.topMargin.leftMargin.equalTo(100)
        }
    }
    
}
