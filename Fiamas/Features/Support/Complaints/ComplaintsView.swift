import SwiftUI

/// Atención de reclamos (sin captura en Figma; sigue el estilo de iOS-ayuda)
struct ComplaintsView: View {
    enum Kind: String, CaseIterable {
        case complaint = "Reclamo"
        case grievance = "Queja"

        var explanation: String {
            switch self {
            case .complaint: "Disconformidad con un monto, producto o pago registrado."
            case .grievance: "Malestar con la atención recibida en la tienda."
            }
        }
    }

    @Environment(AppRouter.self) private var router
    @State private var kind: Kind = .complaint
    @State private var store: String?
    @State private var subject = ""
    @State private var detail = ""
    @State private var ticket: String?

    private let stores = Store.samples.map(\.name)

    private var canSend: Bool {
        store != nil && !subject.trimmingCharacters(in: .whitespaces).isEmpty
            && !detail.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Atención de reclamos", leading: .back, trailingIcon: nil, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("¿Tuviste algún problema?")
                        .font(.poppins(22, .semibold))
                        .foregroundStyle(Color.fiTextPrimary)
                    Text("Cuéntanos qué pasó y te responderemos en un máximo de 15 días hábiles.")
                        .font(.poppins(14))
                        .foregroundStyle(Color.fiTextSecondary)
                        .padding(.top, 4)
                        .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Tipo")
                            kindPicker
                            Text(kind.explanation)
                                .font(.poppins(12))
                                .foregroundStyle(Color.fiTextTertiary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Tienda")
                            storePicker
                        }

                        FiTextField(label: "Asunto", text: $subject, placeholder: "Ej. Monto incorrecto en mi fiado",
                                    icon: "text.bubble", capitalization: .sentences)

                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Detalle")
                            TextField("Describe lo sucedido", text: $detail, axis: .vertical)
                                .font(.poppins(15))
                                .lineLimit(5...8)
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.fiBorder, lineWidth: 1))
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    )

                    FiButton(title: "Enviar \(kind.rawValue.lowercased())", icon: "paperplane.fill", isEnabled: canSend) {
                        ticket = "R-\(Int.random(in: 10000...99999))"
                    }
                    .padding(.top, 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .fiScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .alert(kind == .complaint ? "Reclamo enviado" : "Queja enviada", isPresented: Binding(get: { ticket != nil }, set: { if !$0 { ticket = nil } })) {
            Button("Aceptar") { router.pop() }
        } message: {
            Text("Tu código de seguimiento es \(ticket ?? ""). Te avisaremos por notificación cuando tengamos una respuesta.")
        }
    }

    private var kindPicker: some View {
        HStack(spacing: 4) {
            ForEach(Kind.allCases, id: \.self) { option in
                let isSelected = kind == option
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { kind = option }
                } label: {
                    Text(option.rawValue)
                        .font(.poppins(14, isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected ? .white : Color.fiTextSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(RoundedRectangle(cornerRadius: 10).fill(isSelected ? Color.fiTeal : .clear))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.fiCanvas))
    }

    private var storePicker: some View {
        Menu {
            ForEach(stores, id: \.self) { name in
                Button(name) { store = name }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "storefront")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.fiTextTertiary)
                    .frame(width: 20)
                Text(store ?? "Selecciona una tienda")
                    .font(.poppins(15))
                    .foregroundStyle(store == nil ? Color.fiTextTertiary : Color.fiTextPrimary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.fiTextTertiary)
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.fiBorder, lineWidth: 1))
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.poppins(14, .medium))
            .foregroundStyle(Color.fiTextPrimary)
    }
}

#Preview {
    ComplaintsView().environment(AppRouter())
}
