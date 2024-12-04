import Foundation
import UIKit
import SwiftUI
import ASEntity

struct ResultTableViewItem: Hashable, Sendable {
    let record: Record?
    let submit: Answer?
}

final class HummingResultTableViewDiffableDataSource: UITableViewDiffableDataSource<Int, ResultTableViewItem> {
    
    let viewModel: HummingResultViewModel
    
    init(tableView: UITableView, viewModel: HummingResultViewModel?) {
        guard let viewModel else { return }
        self.viewModel = viewModel
        
        super.init(tableView: tableView) { tableView, indexPath, item in
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            switch indexPath.section {
            case 0:
                guard let record = item.record else { return cell }
                cell.contentConfiguration = UIHostingConfiguration {
                    let currentPlayer = record.player
                    HStack {
                        Spacer()
                        if indexPath.row % 2 == 0 {
                            if let avatarURL = currentPlayer?.avatarUrl {
                                SpeechBubbleCell(
                                    alignment: .left,
                                    messageType: .record,
                                    avatarImagePublisher: { url in
                                        await viewModel.getAvatarData(url: url)
                                    },
                                    avatarURL: avatarURL,
                                    artworkImagePublisher: { url in
                                        await viewModel.getArtworkData(url: url)
                                    },
                                    artworkURL: nil,
                                    name: currentPlayer?.nickname ?? ""
                                )
                            }
                        }
                        else {
                            if let avatarURL = currentPlayer?.avatarUrl {
                                SpeechBubbleCell(
                                    alignment: .right,
                                    messageType: .record,
                                    avatarImagePublisher: { url in
                                        await viewModel.getAvatarData(url: url)
                                    },
                                    avatarURL: avatarURL,
                                    artworkImagePublisher: { url in
                                        await viewModel.getArtworkData(url: url)
                                    },
                                    artworkURL: nil,
                                    name: currentPlayer?.nickname ?? ""
                                )
                            }
                        }
                        Spacer()
                    }
                }
            case 1:
                guard let submit = item.submit else { return cell }
                cell.contentConfiguration = UIHostingConfiguration {
                    HStack {
                        Spacer()
                        if indexPath.row % 2 == 0 {
                            if let avatarURL = submit.player?.avatarUrl,
                               let artworkURL = submit.music?.artworkUrl {
                                SpeechBubbleCell(
                                    alignment: .left,
                                    messageType: .music(submit.music ?? .musicStub1),
                                    avatarImagePublisher: { url in
                                        await viewModel.getAvatarData(url: url)
                                    },
                                    avatarURL: avatarURL,
                                    artworkImagePublisher: { url in
                                        await viewModel.getArtworkData(url: url)
                                    },
                                    artworkURL: artworkURL,
                                    name: submit.player?.nickname ?? ""
                                )
                            }
                        }
                        else {
                            if let submit = viewModel.currentsubmit,
                               let avatarURL = submit.player?.avatarUrl,
                               let artworkURL = submit.music?.artworkUrl {
                                SpeechBubbleCell(
                                    alignment: .right,
                                    messageType: .music(submit.music ?? .musicStub1),
                                    avatarImagePublisher: { url in
                                        await viewModel.getAvatarData(url: url)
                                    },
                                    avatarURL: avatarURL,
                                    artworkImagePublisher: { url in
                                        await viewModel.getArtworkData(url: url)
                                    },
                                    artworkURL: artworkURL,
                                    name: submit.player?.nickname ?? ""
                                )
                            }
                        }
                        Spacer()
                    }
                }
            default:
                return cell
            }
            
            return cell
        }
    }
    
    func applySnapshot(newRecords: [Record], submit: Answer?) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ResultTableViewItem>()
        
        snapshot.appendSections([0, 1])
        
        snapshot.appendItems(newRecords.map {
            ResultTableViewItem(record: $0, submit: nil)
        }, toSection: 0)
        
        if let submit {
            snapshot.appendItems( [ResultTableViewItem(record: nil, submit: submit)],
                                 toSection: 1)
        }
        
        self.apply(snapshot, animatingDifferences: false)
    }
}

