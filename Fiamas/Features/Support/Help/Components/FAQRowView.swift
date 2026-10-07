import SwiftUI

struct FAQRowView: View {
    let faq: FAQ
    let isOpen: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                HStack {
                    Text(faq.question)
                        .font(.poppins(13, .medium))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .frame(minHeight: 40)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                Text(faq.answer)
                    .font(.poppins(11))
                    .foregroundStyle(Color.fiGrayText)
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
            }
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.fiOutline, lineWidth: 1))
    }
}
