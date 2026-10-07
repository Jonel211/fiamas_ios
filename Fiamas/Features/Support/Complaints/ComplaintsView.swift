import SwiftUI

/// Atención de reclamos (sin captura en Figma; sigue el estilo de iOS-ayuda)
struct ComplaintsView: View {
    enum Kind: String, CaseIterable {
        case complaint = "Reclamo"
        case grievance = "Queja"
    }

    @Environment(AppRouter.self) private var router
    @State private var kind: Kind = .complaint
    @State private var store = "Selecciona una tienda"
    @State private var subject = ""
    @State private var detail = ""
    @State private var ticket: String?

    private let stores = Store.samples.map(\.name)

    private var canSend: Bool {
        stores.contains(store) && !subject.trimmingCharacters(in: .whitespaces).isEmpty
            && !detail.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(title: "Atención de reclamos", leading: .back, trailingIcon: nil, color: .fiTealBright, onLeading: { router.pop() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("¿Tuviste algún problema?")
                        .font(.poppins(17))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 6)
                    Text("Cuéntanos qué pasó y te responderemos en un máximo de 15 días hábiles.")
                        .font(.poppins(11))
                        .foregroundStyle(Color.fiGrayText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 22)

                    label("Tipo")
                    kindPicker
                    Text(kind == .complaint
                         ? "Reclamo: disconformidad con un monto, producto o pago registrado."
                         : "Queja: malestar con la atención recibida en la tienda.")
                        .font(.poppins(10))
                        .foregroundStyle(Color.fiGrayText)
                        .padding(.top, 6)

                    label("Tienda")
                    Menu {
                        ForEach(stores, id: \.self) { s in
                            Button(s) { store = s }
                        }
                    } label: {
                        HStack {
                            Text(store)
                                .foregroundStyle(stores.contains(store) ? .black : Color.fiLightGrayText)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.black)
                        }
                        .font(.poppins(12))
                        .padding(.horizontal, 12)
                        .frame(height: 38)
                        .modifier(OutlinedFieldStyle())
                    }

                    label("Asunto")
                    TextField("Ej. Monto incorrecto en mi fiado", text: $subject)
                        .font(.poppins(12))
                        .padding(.horizontal, 12)
                        .frame(height: 38)
                        .modifier(OutlinedFieldStyle())

                    label("Detalle")
                    TextField("Describe lo sucedido", text: $detail, axis: .vertical)
                        .font(.poppins(12))
                        .lineLimit(5...8)
                        .padding(12)
                        .modifier(OutlinedFieldStyle())

                    FiButton(title: "Enviar", color: canSend ? .fiTealBright : .fiTealBright.opacity(0.4),
                             font: .poppins(14, .semibold), height: 40) {
                        ticket = "R-\(Int.random(in: 10000...99999))"
                    }
                    .disabled(!canSend)
                    .padding(.top, 26)
                }
                .padding(.horizontal, 30)
                .padding(.top, 26)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .alert("Reclamo enviado", isPresented: Binding(get: { ticket != nil }, set: { if !$0 { ticket = nil } })) {
            Button("Aceptar") { router.pop() }
        } message: {
            Text("Tu código de seguimiento es \(ticket ?? ""). Te avisaremos por notificación cuando tengamos una respuesta.")
        }
    }

    private var kindPicker: some View {
        HStack(spacing: 10) {
            ForEach(Kind.allCases, id: \.self) { option in
                Button {
                    kind = option
                } label: {
                    Text(option.rawValue)
                        .font(.poppins(12, .medium))
                        .foregroundStyle(kind == option ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(RoundedRectangle(cornerRadius: 8).fill(kind == option ? Color.fiTealBright : .white))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.fiOutline, lineWidth: kind == option ? 0 : 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.poppins(13, .semibold))
            .padding(.top, 16)
            .padding(.bottom, 8)
    }
}

#Preview {
    ComplaintsView().environment(AppRouter())
}
