
//
// View для отображения флага и телефонного кода
//

import UIKit
import SnapKit


class PhoneCodeView: UIView {
    
    public var image: UIImage
    public var text: String
    
    lazy private var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.imageView, self.label])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    lazy private var label: UILabel = {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(named: "TextFieldTextColor")
        return label
    }()
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
        
        super.init(frame: CGRect.zero)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        // базовые установки
        self.layer.backgroundColor = UIColor(named: "TextFieldColor")?.cgColor
        self.layer.borderColor = UIColor(named: "TextFieldBorderColor")?.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 7
        
        // добавляем картинку и текст
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalTo(10)
            make.centerY.equalToSuperview()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
