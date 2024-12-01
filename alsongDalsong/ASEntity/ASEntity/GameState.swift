public struct GameState: Equatable {
    public let mode: Mode?
    public let recordOrder: UInt8?
    public let status: Status?
    public let round: UInt8?
    public let players: [Player]
    public init(
        mode: Mode?,
        recordOrder: UInt8?,
        status: Status?,
        round: UInt8?,
        players: [Player]
    ) {
        self.mode = mode
        self.recordOrder = recordOrder
        self.status = status
        self.round = round
        self.players = players
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
                return .submitMusic
            } else if round == 1, recordOrder == 0 {
                return .humming
            }
        case .rehumming:
            if players.count <= 2, round == 1, recordOrder == 1 {
                return .submitAnswer
            }
            
            if round == 1, recordOrder == players.count - 1 {
                return .submitAnswer
            }
            else if round == 1, recordOrder >= 1 {
                return .rehumming
            }
        case .result:
            if players.count <= 2, recordOrder == 1 {
                return .result
            }
            
            else if recordOrder == players.count - 1 {
                return .result
            }else {
                return nil
            }

        default:
            return .lobby
        }
        return nil
    }

    private func resolveHarmonyViewType(status: Status) -> GameViewType {
        return .submitMusic
    }

    private func resolveSyncViewType(status: Status) -> GameViewType {
        return .submitMusic
    }

    private func resolveInstantViewType(status: Status) -> GameViewType {
        return .submitMusic
    }

    private func resolveTTSViewType(status: Status) -> GameViewType {
        return .submitMusic
    }
}


public enum GameViewType {
    case submitMusic
    case humming
    case rehumming
    case submitAnswer
    case result
    case lobby
}
