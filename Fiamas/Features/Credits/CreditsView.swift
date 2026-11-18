import SwiftUI

struct CreditsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore
    @Environment(DebtsStore.self) private var debtsStore

    @State private var expanded: Set<String> = []

    var mappedSections: [(store: Store, credits: [Credit])] {
        debtsStore.storeSummaries.map { summary in
            let fiados = debtsStore.fiadosAPI.filter { $0.tienda?.id == summary.tienda.id }
            let store = Store(
                id: summary.tienda.id,
                name: summary.tienda.nombre,
                description: "\(fiados.count) fiados registrados",
                date: "",
                used: summary.saldoActual,
                limit: summary.limiteCredito,
                imagenUrl: summary.tienda.imagenUrl ?? fiados.first?.tienda?.imagenUrl
            )
            let credits = fiados.map { f in
                let items = f.detalles.compactMap { detalle in
                    detalle.producto.map { "\($0.nombre) x\(String(format: "%g", detalle.cantidad))" }
                }.joined(separator: ", ")

                let itemDetails: [CreditItem] = f.detalles.map { detalle in
                    let rawUnit = detalle.producto?.unidadMedida?.trimmingCharacters(in: .whitespacesAndNewlines)
                    let unit = (rawUnit?.isEmpty == false) ? rawUnit!.lowercased() : "und"
                    return CreditItem(
                        quantityText: "\(String(format: "%g", detalle.cantidad)) \(unit)",
                        name: detalle.producto?.nombre ?? "Producto",
                        unitPrice: detalle.precioUnitario,
                        subtotal: detalle.subtotal
                    )
                }

                let status: Credit.Status
                if f.estado == "pagado" { status = .paid }
                else if f.estado == "cancelado" { status = .cancelled }
                else if (f.daysUntilDue ?? 0) < 0 { status = .overdue }
                else if f.estado == "parcial" { status = .partial }
                else { status = .pending }

                let rawDate = f.fechaCreacion == "Sin fecha" ? "" : String(f.fechaCreacion.prefix(10))
                let createdText = rawDate.isEmpty ? nil : "Fecha: \(rawDate)"
                let dueText = f.fechaVencimiento.map { "Vence: \($0.prefix(10))" } ?? ""

                return Credit(
                    id: f.id,
                    storeName: summary.tienda.nombre,
                    amount: "S/ \(String(format: "%.2f", f.montoTotal))",
                    totalAmountValue: f.montoTotal,
                    paidAmountValue: f.montoPagado,
                    remainingAmountValue: f.saldoPendiente,
                    items: items.isEmpty ? "Fiado del \(rawDate)" : items,
                    itemDetails: itemDetails,
                    createdAt: createdText,
                    rawCreatedDate: rawDate,
                    date: dueText,
                    status: status,
                    footnote: "\(f.estado.capitalized) · Saldo: S/ \(String(format: "%.2f", f.saldoPendiente))"
                )
            }
            return (store, credits)
        }
        .sorted { $0.store.name < $1.store.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Mis fiados",
                trailingBadge: debtsStore.fiadosAPI.contains { $0.daysUntilDue.map { $0 <= 2 } ?? false },
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(spacing: 14) {
                    if let refreshBannerMessage = debtsStore.refreshBannerMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.exclamationmark")
                            Text(refreshBannerMessage)
                                .font(.poppins(12, .medium))
                            Spacer()
                        }
                        .foregroundStyle(Color.fiDanger)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.fiDanger.opacity(0.1)))
                    }

                    if let errorMessage = debtsStore.errorMessage, !debtsStore.hasLoadedOnce {
                        VStack(spacing: 12) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.fiDanger)
                            Text("No se pudieron cargar tus fiados: \(errorMessage)")
                                .font(.poppins(14))
                                .foregroundStyle(Color.fiTextSecondary)
                                .multilineTextAlignment(.center)
                            Button("Reintentar") {
                                Task { await debtsStore.refresh(profileStore: profileStore, manually: true) }
                            }
                            .font(.poppins(14, .semibold))
                            .foregroundStyle(Color.fiTeal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else if mappedSections.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.fiTextTertiary)
                                .padding(.top, 60)
                            Text("No tienes fiados registrados")
                                .font(.poppins(18, .semibold))
                                .foregroundStyle(Color.fiTextPrimary)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(mappedSections, id: \.store.id) { section in
                            StoreCreditsSectionView(
                                store: section.store,
                                credits: section.credits,
                                isExpanded: expanded.contains(section.store.id),
                                toggle: {
                                    withAnimation(.spring(duration: 0.3)) {
                                        if expanded.contains(section.store.id) {
                                            expanded.remove(section.store.id)
                                        } else {
                                            expanded.insert(section.store.id)
                                        }
                                    }
                                },
                                onSelectCredit: { credit in
                                    router.push(.creditDetail(credit))
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .refreshable { await debtsStore.refresh(profileStore: profileStore, manually: true) }
        }
        .fiScreenBackground()
        .onChange(of: debtsStore.storeSummaries.map(\.id), initial: true) { _, _ in
            if let firstStore = mappedSections.first?.store.id, expanded.isEmpty {
                expanded.insert(firstStore)
            }
        }
    }
}

#Preview {
    CreditsView().environment(AppRouter()).environment(ProfileStore()).environment(DebtsStore())
}
