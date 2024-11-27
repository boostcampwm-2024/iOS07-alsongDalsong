public struct GameState {
    public let mode: Mode?
    public let recordOrder: UInt8?
    public let status: Status?
    public let round: UInt8?

    public init(
        mode: Mode?,
        recordOrder: UInt8?,
        status: Status?,
        round: UInt8?
    ) {
        self.mode = mode
        self.recordOrder = recordOrder
        self.status = status
        self.round = round
    }

    public func resolveViewType() -> GameViewType? {
        guard let mode, let status, let recordOrder, let round else {
            return .lobby
        }
        switch mode {
        case .humming:
            return resolveHummingViewType(status: status, recordOrder: recordOrder, round: round)
        case .harmony:
            return resolveHarmonyViewType(status: status)
        case .sync:
            return resolveSyncViewType(status: status)
        case .instant:
            return resolveInstantViewType(status: status)
        case .tts:
            return resolveTTSViewType(status: status)
        }
    }

    private func resolveHummingViewType(status: Status, recordOrder: UInt8, round: UInt8) -> GameViewType? {
        switch status {
        case .humming:
            if round == 0, recordOrder == 0 {
                return .selectMusic
            } else if round == 1, recordOrder == 0 {
                return .humming
            }
        case .rehumming:
            if round == 1, recordOrder >= 1 {
                return .rehumming
            }
        case .result:
            return .result
        default:
            return .lobby
        }
        return nil
    }

    private func resolveHarmonyViewType(status: Status) -> GameViewType {
        return .selectMusic
    }

    private func resolveSyncViewType(status: Status) -> GameViewType {
        return .selectMusic
    }

    private func resolveInstantViewType(status: Status) -> GameViewType {
        return .selectMusic
    }

    private func resolveTTSViewType(status: Status) -> GameViewType {
        return .selectMusic
    }
}


public enum GameViewType {
    case selectMusic
    case humming
    case rehumming
    case result
    case lobby
}
