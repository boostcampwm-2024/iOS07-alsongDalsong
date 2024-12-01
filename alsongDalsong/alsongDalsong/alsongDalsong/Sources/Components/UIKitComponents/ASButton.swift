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
    ///   - systemImageName: SF Symbol 이미지를 삽입을 원할 경우 "play.fill" 과 같이 systemName 입력.
    ///   - text: 버튼에 쓰일 텍스트
    ///   - textStyle: 버튼에 쓰일 텍스트 스타일
    ///   - backgroundColor: UIColor 형태로 색깔 입력.  (ex) .asYellow)
    func setConfiguration(
        systemImageName: String? = nil,
        text: String? = nil,
        textStyle: UIFont.TextStyle = .largeTitle,
        backgroundColor: UIColor? = nil,
        cornerStyle: UIButton.Configuration.CornerStyle = .medium
    ) {
        var config = UIButton.Configuration.gray()
        config.baseForegroundColor = .asBlack
        config.background.strokeColor = .black
        config.background.strokeWidth = 3
        
        if let systemImageName {
            config.imagePlacement = .leading
            config.image = UIImage(systemName: systemImageName)
            config.imagePadding = 10
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy)
            config.preferredSymbolConfigurationForImage = imageConfig
        }
        
        if let backgroundColor {
            config.baseBackgroundColor = backgroundColor
        }

        if let text {
            var titleAttr = AttributedString(text)
            titleAttr.font = UIFont.font(forTextStyle: textStyle)
            config.attributedTitle = titleAttr
        }

        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        config.cornerStyle = cornerStyle

        setShadow()
        config.background.backgroundColorTransformer = UIConfigurationColorTransformer { color in
            color.withAlphaComponent(1.0)
        }

        configurationUpdateHandler = { [weak self] _ in
            guard let self else { return }
            if isHighlighted {
                transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }
            else {
                transform = .identity
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
            case .submitted:
                setConfiguration(text: type.text)
                disable()
            default: setConfiguration(systemImageName: type.systemImage, text: type.text, backgroundColor: type.backgroundColor)
        }
    }

    enum ASButtonType {
        case disabled
        case needMorePlayers
        case idle(String, UIColor?)
        case startRecord
        case recording
        case reRecord
        case complete
        case submit
        case submitted
        case startGame
        case hostSelecting

        var text: String? {
            switch self {
                case .disabled: nil
                case .needMorePlayers: "게임 인원 부족"
                case let .idle(string, _): string
                case .startRecord: "녹음하기"
                case .recording: "녹음중.."
                case .reRecord: "재녹음"
                case .complete: "완료"
                case .submit: "제출하기"
                case .submitted: "제출 완료"
                case .startGame: "시작하기!"
                case .hostSelecting: "시작 대기 중"
                }
        }

        var systemImage: String? {
            switch self {
                case .startGame: "play.fill"
                case .reRecord: "arrow.clockwise"
                default: nil
            }
        }

        var backgroundColor: UIColor? {
            switch self {
                case .needMorePlayers: .asOrange
                case let .idle(_, color): color
                case .startRecord: .systemRed
                case .recording: .asLightRed
                case .reRecord: .asOrange
                case .complete: .asYellow
                case .submit: .asGreen
                case .startGame: .asMint
                default: nil
            }
        }
    }
}

struct ASButtonWrapper: UIViewRepresentable {
    let systemImageName: String
    let title: String
    let backgroundColor: UIColor
    let textStyle: UIFont.TextStyle = .largeTitle
    func makeUIView(context _: Context) -> ASButton {
        let view = ASButton()
        view.setConfiguration(
            systemImageName: systemImageName,
            text: title,
            textStyle: textStyle,
            backgroundColor: backgroundColor
        )
        return view
    }

    func updateUIView(_: ASButton, context _: Context) {}
}
