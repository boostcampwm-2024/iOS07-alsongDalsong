import ASEntity
import Foundation
import SwiftUI
import UIKit

struct ResultTableViewItem: Hashable, Sendable {
    let record: MappedRecord?
    let submit: MappedAnswer?
}

final class HummingResultTableViewDiffableDataSource: UITableViewDiffableDataSource<Int, ResultTableViewItem> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, item in
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            switch indexPath.section {
                case 0:
                    guard let record = item.record else { return cell }
                    cell.contentConfiguration = UIHostingConfiguration {
                        SpeechBubbleCell(
                            row: indexPath.row,
                            messageType: .record(record)
                        )
                        .padding(.horizontal, 16)
                    }

                case 1:
                    guard let submit = item.submit else { return cell }
                    let recordsCount = tableView.numberOfRows(inSection: 0)
                    cell.contentConfiguration = UIHostingConfiguration {
                        SpeechBubbleCell(
                            row: recordsCount,
                            messageType: .music(submit)
                        )
                        .padding(.horizontal, 16)
                    }
                default:
                    return cell
            }

            return cell
        }
    }

    func applySnapshot(_ result: Result) {
        let records = result.records
        let submit = result.submit

        var snapshot = NSDiffableDataSourceSnapshot<Int, ResultTableViewItem>()

        snapshot.appendSections([0, 1])

        snapshot.appendItems(records.map {
            ResultTableViewItem(record: $0, submit: nil)
        }, toSection: 0)

        if let submit {
            snapshot.appendItems([ResultTableViewItem(record: nil, submit: submit)],
                                 toSection: 1)
        }

        apply(snapshot, animatingDifferences: false)
    }
}
