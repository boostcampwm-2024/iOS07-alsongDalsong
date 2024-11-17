import ASNetworkKit
import ASEntity
import Combine
import UIKit

final class LobbyViewController: UIViewController {
    private var roomInfoLabel = UILabel()
    private var startButton = UIButton()
    
    private let viewModel: LobbyViewModel
    private var cancelables = Set<AnyCancellable>()
    
    init(roomNumber: String) {
        viewModel = LobbyViewModel(roomNumber: roomNumber)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = LobbyViewModel(roomNumber: "")
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        bind()
        viewModel.action(.viewDidLoad)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.action(.viewDidDisappear)
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        roomInfoLabel.numberOfLines = 0
        roomInfoLabel.textColor = .label
        startButton.setTitle("게임 시작", for: .normal)
        startButton.setTitle("게임 시작", for: .disabled)
        startButton.setTitleColor(.blue, for: .normal)
        startButton.setTitleColor(.gray, for: .disabled)
        startButton.addTarget(self, action: #selector(didTapStartGameButton), for: .touchUpInside)
    }
    
    func setupLayout() {
        [roomInfoLabel, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            roomInfoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            roomInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            roomInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            roomInfoLabel.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
            
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    func bind() {
        viewModel.$room
            .receive(on: DispatchQueue.main)
            .sink { [weak self] room in
                guard let room = room else { return }
                self?.configure(room: room)
            }
            .store(in: &cancelables)
        
        viewModel.$startState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isStarted in
                if self?.viewModel.isHost == true {
                    self?.startButton.isEnabled = !isStarted
                }
            }
            .store(in: &cancelables)
    }
    
    func configure(room: Room) {
        let roomDescription =
        """
        Room Number: \(room.number ?? "방 정보 없음")
        Player List: \(room.players?.map { $0.nickname ?? "" }.joined(separator: ", ") ?? "아무도 없음")
        Mode: \(room.mode?.rawValue ?? "")
        Status: \(room.status?.rawValue ?? "")
        Round: \(room.round ?? 0)
        DueTime: \(room.dueTime ?? Date())
        """
        
        roomInfoLabel.text = roomDescription
        startButton.isEnabled = viewModel.isHost
    }
    
    @objc func didTapStartGameButton() {
        viewModel.action(.startGame)
    }
}
