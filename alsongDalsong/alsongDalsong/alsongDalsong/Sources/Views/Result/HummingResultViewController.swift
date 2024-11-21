import UIKit
import SwiftUI
import ASEntity
import Combine

class HummingResultViewController: UIViewController {
    private let musicResultView = MusicResultView(frame: .zero)
    private let resultTableView = UITableView()
    private let button = ASButton()
    let testArr = [1,2,3,4]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMusicResultView()
        setResultTableView()
        setButton()
        setConstraints()
    }
    
    private func setMusicResultView() {
        musicResultView.setConfig(albumImagePublisher: Just(Data())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher(),
                                  musicName: "모조조조",
                                  singerName: "이게 모죠")
        view.addSubview(musicResultView)
    }
    
    private func setResultTableView() {
        resultTableView.dataSource = self
        resultTableView.separatorStyle = .none
        view.addSubview(resultTableView)
    }
    
    private func setButton() {
        button.setConfiguration(systemImageName: "play.fill", title: "다음으로", backgroundColor: .asMint)
        view.addSubview(button)
    }
    
    private func setConstraints() {
        musicResultView.translatesAutoresizingMaskIntoConstraints = false
        resultTableView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            musicResultView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                musicResultView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                musicResultView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                musicResultView.heightAnchor.constraint(equalToConstant: 130),
            
            resultTableView.topAnchor.constraint(equalTo: musicResultView.bottomAnchor, constant: 20),
            resultTableView.leadingAnchor.constraint(equalTo: musicResultView.leadingAnchor),
            resultTableView.trailingAnchor.constraint(equalTo: musicResultView.trailingAnchor),
            resultTableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -30),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            button.heightAnchor.constraint(equalToConstant: 64),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
}

extension HummingResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentConfiguration = UIHostingConfiguration {
            if indexPath.row % 2 == 0 {
                SpeechBubbleCell(alignment: .left,
                                 messageType: .music(Music(title: "Hello", artist: "허각")))
            } else {
                SpeechBubbleCell(alignment: .right,
                                 messageType: .record(.init()))
            }
        }
        
        return cell
    }
    
}

final class MusicResultView: UIView {
    private let albumImageView = UIImageView()
    private let musicNameLabel = UILabel()
    private let singerNameLabel = UILabel()
    private let titleLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    func setConfig(albumImagePublisher: AnyPublisher<Data?, Error>, musicName: String, singerName: String) {
        self.musicNameLabel.text = musicName
        self.singerNameLabel.text = singerName
        fetchAlbumImage(from: albumImagePublisher)
    }

    private func setupView() {
        titleLabel.text = "정답은..."
        titleLabel.font = UIFont(name: "Dohyeon-Regular", size: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        albumImageView.contentMode = .scaleAspectFill
        albumImageView.layer.cornerRadius = 6
        albumImageView.clipsToBounds = true
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumImageView.image = UIImage(named: "mojojojo") // Placeholder image
        addSubview(albumImageView)

        musicNameLabel.font = UIFont(name: "Dohyeon-Regular", size: 24)
        musicNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(musicNameLabel)

        singerNameLabel.font = UIFont(name: "Dohyeon-Regular", size: 24)
        singerNameLabel.textColor = UIColor.asLightGray
        singerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(singerNameLabel)
        
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.asShadow.cgColor
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowRadius = 0
        layer.shadowOpacity = 1.0
        layer.borderWidth = 3
        layer.borderColor = UIColor.black.cgColor
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            albumImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            albumImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            albumImageView.widthAnchor.constraint(equalToConstant: 60),
            albumImageView.heightAnchor.constraint(equalToConstant: 60),

            musicNameLabel.topAnchor.constraint(equalTo: albumImageView.topAnchor),
            musicNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 15),
            musicNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            singerNameLabel.topAnchor.constraint(equalTo: musicNameLabel.bottomAnchor, constant: 4),
            singerNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 15),
            singerNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func fetchAlbumImage(from publisher: AnyPublisher<Data?, Error>) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] data in
                guard let self = self, let data = data, let image = UIImage(data: data) else { return }
                self.albumImageView.image = image
            })
            .store(in: &cancellables)
    }
}

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif

struct HummingResultPreview: PreviewProvider {
    static var previews: some View {
        HummingResultViewController().toPreview()
    }
}
