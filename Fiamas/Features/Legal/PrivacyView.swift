import SwiftUI

/// iOS-privacidad
struct PrivacyView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            // Header estándar del DesignSystem de la app
            FiHeader(title: "Política de privacidad", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            // Tarjeta flotante estructurada según el diseño
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(LegalText.Privacy.intro)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Privacy.collectIntro)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    // Datos recopilados
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(LegalText.Privacy.collectedData, id: \.self) { item in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(.poppins(14, .bold))
                                    .foregroundStyle(Color.fiTeal)
                                Text(item)
                                    .font(.poppins(14))
                                    .foregroundStyle(Color.fiTextPrimary)
                                    .lineSpacing(2)
                            }
                        }
                    }

                    Text(LegalText.Privacy.purposesIntro)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    // Fines
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(LegalText.Privacy.purposes, id: \.self) { purpose in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(.poppins(14, .bold))
                                    .foregroundStyle(Color.fiTeal)
                                Text(purpose)
                                    .font(.poppins(14))
                                    .foregroundStyle(Color.fiTextPrimary)
                                    .lineSpacing(2)
                            }
                        }
                    }

                    Text(LegalText.Privacy.dataSecurity)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Privacy.retention)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Privacy.thirdPartiesIntro)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    // Terceros
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(LegalText.Privacy.thirdParties, id: \.self) { thirdParty in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(.poppins(14, .bold))
                                    .foregroundStyle(Color.fiTeal)
                                Text(thirdParty)
                                    .font(.poppins(14))
                                    .foregroundStyle(Color.fiTextPrimary)
                                    .lineSpacing(2)
                            }
                        }
                    }

                    Text(LegalText.Privacy.rights)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Privacy.updates)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    Text(LegalText.Privacy.contactIntro)
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineSpacing(3)

                    // Canales de contacto
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(LegalText.Privacy.contactChannels, id: \.self) { channel in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(.poppins(14, .bold))
                                    .foregroundStyle(Color.fiTeal)
                                Text(channel)
                                    .font(.poppins(14))
                                    .foregroundStyle(Color.fiTextPrimary)
                                    .lineSpacing(2)
                            }
                        }
                    }

                    // Botón Entendido con estilo de acento del sistema
                    FiButton(title: "Entendido", style: .accent) {
                        router.pop()
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
    PrivacyView().environment(AppRouter())
}
