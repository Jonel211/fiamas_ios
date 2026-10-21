import SwiftUI

/// Pregunta frecuente que se despliega al tocarla.
struct FAQRowView: View {
    let faq: FAQ
    let isOpen: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                HStack(spacing: 12) {
                    Text(faq.question)
                        .font(.poppins(15, .medium))
                        .foregroundStyle(Color.fiTextPrimary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isOpen ? Color.fiTeal : Color.fiTextTertiary)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                Text(faq.answer)
                    .font(.poppins(14))
                    .foregroundStyle(Color.fiTextSecondary)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity)
            }
        }
    }
}
