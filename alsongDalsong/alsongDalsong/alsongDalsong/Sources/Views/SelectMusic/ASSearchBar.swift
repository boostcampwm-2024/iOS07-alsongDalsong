import SwiftUI

struct ASSearchBar: View {
    @Binding var text: String
    var placeHolder: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
 
                TextField(placeHolder, text: $text)
                    .foregroundColor(.primary)
 
                if !text.isEmpty {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                } else {
                    EmptyView()
                }
            }
            .padding(8)
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ASSearchBar(text: .constant(""), placeHolder: "검색하세요")
}
