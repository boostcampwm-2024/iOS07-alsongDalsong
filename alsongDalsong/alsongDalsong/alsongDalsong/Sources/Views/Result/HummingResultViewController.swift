import UIKit
import SwiftUI
import ASEntity
import Combine

class HummingResultViewController: UIViewController {
    private let musicResultView = MusicResultView(frame: .zero)
    private let resultTableView = UITableView()
    private let button = ASButton()
    let testArr = [1,2,3,4]
    
    private var viewModel = HummingResultViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .asLightGray
        viewModel.fetchResult()
        setMusicResultView(musicName: "", singerName: "")
        setResultTableView()
        setButton()
        setConstraints()
        bind()
    }
    
    //TODO: 앨범 커버URL 던지기
    private func setMusicResultView(musicName: String, singerName: String) {
        musicResultView.setConfig(albumImagePublisher: Just(Data())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher(),
                                  musicName: musicName,
                                  singerName: singerName)
        view.addSubview(musicResultView)
    }
    
    private func setResultTableView() {
        resultTableView.dataSource = self
        resultTableView.separatorStyle = .none
        resultTableView.allowsSelection = false
        resultTableView.backgroundColor = .asLightGray
        view.addSubview(resultTableView)
    }
    
    private func setButton() {
        button.setConfiguration(systemImageName: "play.fill", title: "다음으로", backgroundColor: .asMint)
        view.addSubview(button)
        button.addAction(UIAction { [weak self] _ in
            let vc = self?.navigationController?.viewControllers.first(where: { $0 is LobbyViewController })
            guard let vc else { return }
            self?.navigationController?.popToViewController(vc, animated: true)
        }, for: .touchUpInside)
    }
    
    private func setConstraints() {
        musicResultView.translatesAutoresizingMaskIntoConstraints = false
        resultTableView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            musicResultView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 20),
            musicResultView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            musicResultView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            musicResultView.heightAnchor.constraint(equalToConstant: 130),
            
            resultTableView.topAnchor.constraint(equalTo: musicResultView.bottomAnchor, constant: 20),
            resultTableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            resultTableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            resultTableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -30),
            
            button.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -24),
            button.heightAnchor.constraint(equalToConstant: 64),
            button.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -25)
        ])
    }
    
    private func bind() {
        viewModel.$currentResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] answer in
                self?.setMusicResultView(musicName: answer?.music.title ?? "", singerName: answer?.music.artist ?? "")
            }
            .store(in: &cancellables)
        viewModel.$resultRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.resultTableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$answer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] answer in
                //TODO: 정답 제출한 음악 뷰에 주는 거 (TableView가 보고 있는 배열에 추가?)
                // OR 뷰 하나를 새로 해서 테이블 뷰 바로 아래에 뷰 추가
            }
            .store(in: &cancellables)
    }
}

extension HummingResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.resultRecords.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        
        if indexPath.section == 0 {
            cell.contentConfiguration = UIHostingConfiguration {
                if indexPath.row % 2 == 0 {
                    SpeechBubbleCell(alignment: .left,
                                     messageType: .record(viewModel.resultRecords[indexPath.row]))
                } else {
                    SpeechBubbleCell(alignment: .right,
                                     messageType: .record(viewModel.resultRecords[indexPath.row]))
                }
            }
        } else {
            cell.contentConfiguration = UIHostingConfiguration {
                if viewModel.resultRecords.count % 2 == 0 {
                    SpeechBubbleCell(
                        alignment: .left,
                        messageType: .music(
                            .init(
                                title: viewModel.answer?.music.title ?? "",
                                artist: viewModel.answer?.music.artist ?? ""
                            )
                        )
                    )
                }
                else {
                    SpeechBubbleCell(
                        alignment: .right,
                        messageType: .music(
                            .init(
                                title: viewModel.answer?.music.title ?? "",
                                artist: viewModel.answer?.music.artist ?? ""
                            )
                        )
                    )
                }
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
