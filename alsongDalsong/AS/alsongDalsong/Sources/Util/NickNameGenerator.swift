import Foundation

enum NickNameGenerator {
    static func generate() -> String {
        let staffName = ["틀틀보", "도덕적인 삶", "쏘니", "로얄 iOS핑"]
        let adjectives = ["부드러운", "도덕적인", "뽀송뽀송한", "축축한", "화가 많은", "건전한", "반짝반짝한"]
        let nouns = ["삶", "초코칩", "머리", "두피", "개발자", "좀도둑", "사냥꾼", "취객", "루돌프", "사부님", "강아지"]
        
        if Int.random(in: 0 ..< 1000) == 0 {
            return staffName.randomElement() ?? "멋진 닉네임"
        }
        
        if let adjective = adjectives.randomElement(),
           let noun = nouns.randomElement() {
            return "\(adjective) \(noun)"
        }
        
        return "멋진 닉네임"
    }
}
