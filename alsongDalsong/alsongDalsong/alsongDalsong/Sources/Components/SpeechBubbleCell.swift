import ASEntity
import Combine
import SwiftUI
import UIKit

enum MessageType {
    case music(MappedAnswer)
    case record(MappedRecord)

    var bubbleHeight: CGFloat {
        switch self {
            case .music:
                return 90
            case .record:
                return 64
        }
    }
}

enum MessageAlignment {
    case left
    case right
}

struct SpeechBubbleCell: View {
    let row: Int
    let messageType: MessageType
    private var alignment: MessageAlignment {
        row.isMultiple(of: 2) ? .left : .right
    }

    private var playerInfo: PlayerInfo {
        switch messageType {
            case let .music(music): return music
            case let .record(record): return record
        }
    }

    var body: some View {
        if alignment == .left {
            HStack(spacing: 12) {
                avatarView(info: playerInfo)
                speechBubble
            }
        }
        if alignment == .right {
            HStack(spacing: 12) {
                speechBubble
                avatarView(info: playerInfo)
            }
        }
    }

    @ViewBuilder
    private var speechBubble: some View {
        ZStack {
            contentView
                .padding(.bottom, 8)
                .padding(.leading, alignment == .left ? 36 : 0)
                .frame(width: 230, height: messageType.bubbleHeight)
                .bubbleStyle(
                    alignment: alignment,
                    fillColor: .asSystem,
                    borderColor: .black,
                    lineWidth: 5
                )
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch messageType {
            case let .music(music):
                HStack {
                    artworkView(music)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading) {
                        Text(music.title)
                            .foregroundStyle(.asBlack)

                        Text(music.artist)
                            .foregroundStyle(.gray)
                    }
                    .frame(width: 130)
                    .font(.custom("Dohyeon-Regular", size: 20))
                    .lineLimit(1)
                    Spacer()
                }
            case let .record(record):
                HStack {
                    WaveFormWrapper(columns: record.recordAmplitudes, sampleCount: 24, circleColor: .asBlack, highlightColor: .asGreen)
                        .frame(width: 200)
                    Spacer()
                }
        }
    }

    @ViewBuilder
    private func avatarView(info: PlayerInfo) -> some View {
        VStack {
            Image(uiImage: UIImage(data: info.playerAvatarData) ?? UIImage())
                .resizable()
                .background(Color.asMint)
                .aspectRatio(contentMode: .fill)
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 5)
                )
                .padding(.bottom, 4)
            Text(info.playerName)
                .font(.doHyeon(size: 16))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 75)
    }

    @ViewBuilder
    private func artworkView(_ music: MappedAnswer) -> some View {
        Image(uiImage: UIImage(data: music.artworkData) ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

struct BubbleShape: Shape {
    let alignment: MessageAlignment

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if alignment == .right {
            addSpeechTailRight(&path, in: rect)
            addRoundedBody(&path, in: rect, isRight: true)
        } else {
            addRoundedBody(&path, in: rect, isRight: false)
            addSpeechTailLeft(&path, in: rect)
        }
        path.closeSubpath()
        return path
    }

    private func addSpeechTailRight(_ path: inout Path, in rect: CGRect) {
        path.move(to: CGPoint(x: rect.maxX - 40, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.minY + 16))
        path.addLine(to: CGPoint(x: rect.maxX - 40, y: rect.minY))
    }

    private func addSpeechTailLeft(_ path: inout Path, in rect: CGRect) {
        path.move(to: CGPoint(x: rect.minX + 8, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + 40, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + 20, y: rect.minY + 16))
        path.addLine(to: CGPoint(x: rect.minX + 8, y: rect.minY))
    }

    private func addRoundedBody(_ path: inout Path, in rect: CGRect, isRight: Bool) {
        let xOffset: CGFloat = isRight ? -10 : 20
        path.addRoundedRect(
            in: CGRect(x: rect.minX + xOffset, y: rect.minY, width: rect.width - 10, height: rect.height - 10),
            cornerSize: CGSize(width: 12, height: 12)
        )
    }
}

struct BubbleBackgroundModifier: ViewModifier {
    let alignment: MessageAlignment
    let fillColor: Color
    let borderColor: Color
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    BubbleShape(alignment: alignment)
                        .stroke(borderColor, lineWidth: lineWidth)
                    BubbleShape(alignment: alignment)
                        .fill(fillColor)
                        .shadow(color: .asShadow, radius: 0, x: 6, y: 6)
                }
            )
    }
}

extension View {
    func bubbleStyle(alignment: MessageAlignment, fillColor: Color, borderColor: Color, lineWidth: CGFloat) -> some View {
        modifier(BubbleBackgroundModifier(alignment: alignment, fillColor: fillColor, borderColor: borderColor, lineWidth: lineWidth))
    }
}
