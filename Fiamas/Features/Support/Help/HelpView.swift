import SwiftUI

/// iOS-ayuda
struct HelpView: View {
    @Environment(AppRouter.self) private var router
    @State private var openFAQ: Set<UUID> = []

    private let faqs = FAQ.samples

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Ayuda", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("¿Cómo podemos ayudarte hoy?")
                        .font(.poppins(22, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                        .padding(.bottom, 16)

                    contactCard
                        .padding(.bottom, 28)

                    SectionHeader(title: "Preguntas frecuentes")
                        .padding(.bottom, 12)

                    VStack(spacing: 0) {
                        ForEach(faqs) { faq in
                            FAQRowView(faq: faq, isOpen: openFAQ.contains(faq.id)) {
                                withAnimation(.spring(duration: 0.3)) {
                                    if openFAQ.contains(faq.id) {
                                        openFAQ.remove(faq.id)
                                    } else {
                                        openFAQ.insert(faq.id)
                                    }
                                }
                            }
                            if faq.id != faqs.last?.id {
                                FiDivider(leadingInset: 16)
                            }
                        }
                    }
                    .fiCard(padding: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var contactCard: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("¿Tienes alguna duda?")
                    .font(.poppins(18, .semibold))
                Text("Estamos aquí para apoyarte con tu tienda.")
                    .font(.poppins(14))
                    .opacity(0.9)
                    .padding(.bottom, 12)

                Button { router.push(.complaints) } label: {
                    Label("Escríbenos", systemImage: "bubble.left.fill")
                        .font(.poppins(14, .semibold))
                        .foregroundStyle(Color.fiTealDark)
                        .padding(.horizontal, 16)
                        .frame(height: 40)
                        .background(Capsule().fill(.white))
                }
                .buttonStyle(PressableButtonStyle())
            }
            Spacer(minLength: 0)
            Image(systemName: "questionmark.bubble.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.25))
        }
        .foregroundStyle(.white)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [.fiTeal, .fiTealDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.fiTealDark.opacity(0.25), radius: 12, y: 6)
        )
    }
}

#Preview {
    HelpView().environment(AppRouter())
}
