//
//  ASTextField.swift
//  alsongDalsong
//
//  Created by Minha Lee on 11/14/24.
//

import UIKit

class ASTextField: UITextField {
    init(
        placeholder: String = "텍스트를 입력하세요",
        backgroundColor: UIColor = .white,
        textSize: CGFloat = 32
    ) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.lightGray])
        self.backgroundColor = backgroundColor
        font = UIFont.font(.dohyeon, ofSize: textSize)
        textColor = .black
        attributedText?.addObserver(self, forKeyPath: "string", options: .new, context: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
