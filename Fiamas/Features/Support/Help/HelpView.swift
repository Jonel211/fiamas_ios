import SwiftUI

/// iOS-ayuda
struct HelpView: View {
    @Environment(AppRouter.self) private var router
    @State private var openFAQ: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Ayuda", leading: .back, trailingIcon: nil, color: .fiTealBright, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("¿Como podemos ayudarte hoy?")
                        .font(.poppins(17))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)

                    contactCard
                        .padding(.bottom, 24)

                    Text("Preguntas Frecuentes")
                        .font(.poppins(15, .semibold))
                        .padding(.bottom, 16)

                    VStack(spacing: 22) {
                        ForEach(FAQ.samples) { faq in
                            FAQRowView(faq: faq, isOpen: openFAQ.contains(faq.id)) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if openFAQ.contains(faq.id) {
                                        openFAQ.remove(faq.id)
                                    } else {
                                        openFAQ.insert(faq.id)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 26)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("¿Tienes alguna duda?")
                .font(.poppins(15, .bold))
            Text("Estamos aqui para apoyarte con tu tienda")
                .font(.poppins(13))
                .lineSpacing(3)
                .padding(.bottom, 12)

            Button {
                router.push(.complaints)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "message")
                        .font(.system(size: 13, weight: .medium))
                    Text("Escribenos")
                        .font(.poppins(14))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 10)
                .frame(height: 34)
                .background(RoundedRectangle(cornerRadius: 4).fill(.white))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.fiTealBright))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.fiCardOutline, lineWidth: 0.8))
    }
}

#Preview {
    HelpView().environment(AppRouter())
}
