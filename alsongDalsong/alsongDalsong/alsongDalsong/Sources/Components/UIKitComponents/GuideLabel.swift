import UIKit

final class GuideLabel: UILabel {
    init() {
        super.init(frame: .zero)
        font = .font(forTextStyle: .largeTitle)
        textColor = .label
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(_ text: String) {
        self.text = text
    }
}
