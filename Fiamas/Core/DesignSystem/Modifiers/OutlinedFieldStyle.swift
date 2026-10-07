import SwiftUI

struct OutlinedFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: 8).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.fiOutline, lineWidth: 1))
    }
}
