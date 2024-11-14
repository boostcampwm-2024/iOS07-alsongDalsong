//
//  ASRefreshButton.swift
//  alsongDalsong
//
//  Created by Minha Lee on 11/14/24.
//

import UIKit

class ASRefreshButton: UIButton {
    init(size: CGFloat) {
        super.init(frame: .zero)
        setConfiguration(size: size)
    }
    private func setConfiguration(size: CGFloat) {
        var config = UIButton.Configuration.gray()
        
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .asShadow
        
        config.imagePlacement = .all
        config.image = UIImage(systemName: "arrow.clockwise")
//        config.imagePadding = 10
        config.cornerStyle = .capsule
//        config.background.strokeColor = .black
//        config.background.strokeWidth = 3
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: size, weight: .bold)
        config.preferredSymbolConfigurationForImage = imageConfig
        
//        var titleAttr = AttributedString.init(title)
//        titleAttr.font = UIFont.font(.dohyeon, ofSize: 32)
//        config.attributedTitle = titleAttr
        
//        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        config.cornerStyle = .capsule
        
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
