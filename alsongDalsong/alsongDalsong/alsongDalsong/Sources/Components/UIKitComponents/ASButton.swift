import UIKit

class ASButton: UIButton {
    init(
        systemImageName: String = "",
        title: String,
        backgroundColor: UIColor,
        textSize: CGFloat = 32
    ) {
        super.init(frame: .zero)
        setConfiguration(
            systemImageName: systemImageName,
            title: title,
            backgroundColor: backgroundColor,
            textSize: textSize
        )
        setShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 버튼의 UI 관련한 Configuration을 설정하는 메서드
    /// - Parameters:
    ///   - systemImageName: SF Symbol 이미지를 삽입을 원할 경우 "play.fill" 과 같이 systemName 입력. 입력 안할시 이미지 입력 안됨.
    ///   - title: 버튼에 쓰일 텍스트
    ///   - backgroundColor: UIColor 형태로 색깔 입력.  (ex.   .asYellow)
    private func setConfiguration(
        systemImageName: String,
        title: String,
        backgroundColor: UIColor,
        textSize: CGFloat = 32
    ) {
        var config = UIButton.Configuration.gray()
        
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = .black
        
        config.imagePlacement = .leading
        config.image = UIImage(systemName: systemImageName)
        config.imagePadding = 10
        
        config.background.strokeColor = .black
        config.background.strokeWidth = 3
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy)
        config.preferredSymbolConfigurationForImage = imageConfig
        
        var titleAttr = AttributedString.init(title)
        titleAttr.font = UIFont.font(.dohyeon, ofSize: textSize)
        config.attributedTitle = titleAttr
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        config.cornerStyle = .medium
        
        self.configuration = config
    }
}
