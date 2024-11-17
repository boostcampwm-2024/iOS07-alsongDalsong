import Foundation

struct JSONDataScenarios {
    static let correctData = """
        {
            "id": 1,
            "user_name": "아이유",
            "user_avatar_url": "https://www.apple.com",
            "user_birth_date": "2024-10-20T10:00:00Z",
            "user_status": "waiting"
        }
        """.data(using: .utf8)!

    static let missingFieldData = """
        {
            "id": 1,
            "user_name": "에스파",
            "user_avatar_url": "https://www.apple.com"
        }
        """.data(using: .utf8)!

    static let incorrectFormatData = """
        {
            "id": "one",
            "user_name": "뉴진스",
            "user_avatar_url": "https://www.apple.com",
            "user_birth_date": "2024-10-20T10:00:00Z",
            "user_status": "humming"
        }
        """.data(using: .utf8)!
}
