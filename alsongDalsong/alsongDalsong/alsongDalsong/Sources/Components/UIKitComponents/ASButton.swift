import Combine
import SwiftUI
import UIKit

final class ASButton: UIButton {
    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// 버튼의 UI 관련한 Configuration을 설정하는 메서드
    /// - Parameters:
    ///   - systemImageName: SF Symbol 이미지를 삽입을 원할 경우 "play.fill" 과 같이 systemName 입력. 입력 안할시 이미지 입력 안됨.
    ///   - title: 버튼에 쓰일 텍스트
    ///   - backgroundColor: UIColor 형태로 색깔 입력.  (ex.   .asYellow)
    func setConfiguration(
        systemImageName: String? = nil,
        title: String?,
        backgroundColor: UIColor? = nil,
        textSize: CGFloat = 32
    ) {
        var config = UIButton.Configuration.gray()
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = .asBlack

        if let systemImageName {
            config.imagePlacement = .leading
            config.image = UIImage(systemName: systemImageName)
            config.imagePadding = 10
        }

        config.background.strokeColor = .black
        config.background.strokeWidth = 3

        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy)
        config.preferredSymbolConfigurationForImage = imageConfig

        var titleAttr = AttributedString(title ?? "")
        titleAttr.font = UIFont.font(.dohyeon, ofSize: textSize)
        config.attributedTitle = titleAttr

        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        config.cornerStyle = .medium

        setShadow()
        config.background.backgroundColorTransformer = UIConfigurationColorTransformer { color in
            color.withAlphaComponent(1.0)
        }

        configurationUpdateHandler = { [weak self] _ in
            guard let self else { return }
            if self.isHighlighted {
                self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }
            else {
                self.transform = .identity
            }
        }
        configuration = config
    }

    private func disable(_ color: UIColor = .systemGray2) {
        configuration?.baseBackgroundColor = color
        isEnabled = false
    }

    func bind(
        to dataSource: Published<Data?>.Publisher
    ) {
        dataSource
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newHumming in
                if newHumming == nil { return }
                self?.isEnabled = true
                self?.configuration?.baseBackgroundColor = .asGreen
            }
            .store(in: &cancellables)
    }

    func updateButton(_ type: ASButton.ASButtonType) {
        switch type {
            case .disabled: disable()
            case .waitStart: setConfiguration(title: "시작 대기중..", backgroundColor: .asOrange)
            case let .idle(string, color): setConfiguration(title: string, backgroundColor: color)
            case .startRecord: setConfiguration(title: "녹음하기", backgroundColor: .systemRed)
            case .recording: setConfiguration(title: "녹음중..", backgroundColor: .asLightRed)
            case .reRecord: setConfiguration(systemImageName: "arrow.clockwise", title: "재녹음", backgroundColor: .asOrange)
            case .submit: setConfiguration(title: "제출하기", backgroundColor: .asGreen)
            case .complete: setConfiguration(title: "완료")
            case .submitted:
                setConfiguration(title: "제출 완료")
                disable()
            case .startGame: setConfiguration(systemImageName: "play.fill", title: "시작하기!", backgroundColor: .asMint)
        }
    }

    enum ASButtonType {
        case disabled
        case waitStart
        case idle(String, UIColor?)
        case startRecord
        case recording
        case reRecord
        case complete
        case submit
        case submitted
        case startGame
    }
}

struct ASButtonWrapper: UIViewRepresentable {
    let systemImageName: String
    let title: String
    let backgroundColor: UIColor
    let textSize: CGFloat = 32
    func makeUIView(context _: Context) -> ASButton {
        let view = ASButton()
        view.setConfiguration(systemImageName: systemImageName, title: title, backgroundColor: backgroundColor, textSize: textSize)
        return view
    }

    func updateUIView(_: ASButton, context _: Context) {}
}
