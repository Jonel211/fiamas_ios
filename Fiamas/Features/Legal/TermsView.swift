import SwiftUI

/// iOS-terminos
struct TermsView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            // Header estándar del DesignSystem
            FiHeader(title: "Términos y condiciones", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            // Tarjeta flotante estructurada según el diseño
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(LegalText.Terms.intro)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.description)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    // Lista de viñetas
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(LegalText.Terms.features, id: \.self) { feature in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(.poppins(14, .bold))
                                    .foregroundStyle(Color.fiTeal)
                                Text(feature)
                                    .font(.poppins(14))
                                    .foregroundStyle(Color.fiTextPrimary)
                                    .lineSpacing(2)
                            }
                        }
                    }

                    Text(LegalText.Terms.responsibility)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.accuracy)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.internalUse)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.consent)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.reports)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.noInvoice)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.property)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.balance)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.availability)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.updates)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Terms.contact)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    // MARK: - Botones de Acción (Rechazar / Aceptar y Continúa en 2 filas)
                    HStack(spacing: 12) {
                        Button(action: { router.pop() }) {
                            Text("Rechazar")
                                .font(.poppins(14, .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(red: 0.90, green: 0.68, blue: 0.25))
                                .cornerRadius(12)
                        }

                        Button(action: { router.pop() }) {
                            Text("Aceptar y\nContinúa")
                                .font(.poppins(13, .bold))
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.fiTeal)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 14)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.fiTeal.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    TermsView().environment(AppRouter())
}
