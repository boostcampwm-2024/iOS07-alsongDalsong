import UIKit
import SwiftUI
import ASEntity
import Combine

class HummingResultViewController: UIViewController {
    private let musicResultView = MusicResultView(frame: .zero)
    private let resultTableView = UITableView()
    private let button = ASButton()
    
    private var viewModel: HummingResultViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: HummingResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .asLightGray
        setMusicResultView(musicName: viewModel?.currentResult?.music?.title ?? "",
                           singerName: viewModel?.currentResult?.music?.artist ?? "")
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
            guard let self,
                  let viewModel = self.viewModel else {return}
            if !(viewModel.hummingResult.isEmpty) {
                viewModel.nextResultFetch()
                setMusicResultView(musicName: viewModel.currentResult?.music?.title ?? "",
                                   singerName: viewModel.currentResult?.music?.artist ?? "")
                resultTableView.reloadData()
                button.isHidden = true
            }
            else {
                let vc = self.navigationController?.viewControllers.first(where: { $0 is LobbyViewController })
                guard let vc else { return }
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }, for: .touchUpInside)
        button.isHidden = true
    }
    
    private func setConstraints() {
        view.addSubview(musicResultView)
        
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
        viewModel?.$currentResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] answer in
                guard let answer,
                      let music = answer.music else {return}
                self?.setMusicResultView(musicName: music.title ?? "", singerName: music.artist ?? "")
                self?.viewModel?.startPlaying()
            }
            .store(in: &cancellables)
        viewModel?.$currentRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.resultTableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel?.$currentsubmit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] submit in
                if (submit != nil) {
                    self?.resultTableView.reloadData()
                    self?.button.isHidden = false
                }
            }
            .store(in: &cancellables)
    }
}

extension HummingResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else {return 0}
        if section == 0 {
            return viewModel.currentRecords.count
        }
        if (viewModel.currentsubmit != nil) {
            return 1
        }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        guard let viewModel else {return cell}
        
        if indexPath.section == 0 {
            cell.contentConfiguration = UIHostingConfiguration {
                if indexPath.row % 2 == 0 {
                    SpeechBubbleCell(alignment: .left,
                                     messageType: .record(viewModel.currentRecords[indexPath.row]))
                } else {
                    SpeechBubbleCell(alignment: .right,
                                     messageType: .record(viewModel.currentRecords[indexPath.row]))
                }
            }
        } else {
            cell.contentConfiguration = UIHostingConfiguration {
                if viewModel.currentRecords.count % 2 == 0 {
                    SpeechBubbleCell(
                        alignment: .left,
                        messageType: .music(
                            .init(
                                title: viewModel.currentsubmit?.music?.title ?? "",
                                artist: viewModel.currentsubmit?.music?.artist ?? ""
                            )
                        )
                    )
                }
                else {
                    SpeechBubbleCell(
                        alignment: .right,
                        messageType: .music(
                            .init(
                                title: viewModel.currentsubmit?.music?.title ?? "",
                                artist: viewModel.currentsubmit?.music?.artist ?? ""
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

//struct HummingResultPreview: PreviewProvider {
//    static var previews: some View {
//        HummingResultViewController().toPreview()
//    }
//}
