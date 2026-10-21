import SwiftUI

struct CreditsView: View {
    @Environment(AppRouter.self) private var router
    
    @State private var fiadosAPI: [FiadoAPI] = []
    @State private var isLoading = true
    @State private var expanded: Set<String> = []

    // TRADUCCIÓN: Convertimos los FiadoAPI en Store y Credit para tus componentes
    var mappedSections: [(store: Store, credits: [Credit])] {
        var dict: [String: (storeName: String, fiados: [FiadoAPI])] = [:]
        
        // 1. Agrupamos por tienda
        for fiado in fiadosAPI {
            let tId = fiado.tienda?.id ?? "unknown"
            let tName = fiado.tienda?.nombre ?? "Tienda Desconocida"
            if dict[tId] == nil { dict[tId] = (tName, []) }
            dict[tId]?.fiados.append(fiado)
        }
        
        // 2. Convertimos a tus modelos visuales
        return dict.map { (_, value) in
            // Calculamos el total usado para la barra
            let totalUsed = value.fiados.reduce(0) { $0 + Int($1.saldoPendiente) }
            
            let store = Store(
                name: value.storeName,
                description: "",
                date: "",
                used: totalUsed,
                limit: 1000 // Límite ficticio para la barra visual
            )
            
            let credits = value.fiados.map { f in
                // Corregimos el mapeo del estado: Si es "vencido" es rojo, si no, es pendiente (naranja)
                let uiStatus: Credit.Status = (f.estado == "vencido") ? .overdue : .pending
                
                return Credit(
                    amount: "S/ \(String(format: "%.2f", f.montoTotal))",
                    items: "Fiado del " + String(f.fechaCreacion.prefix(10)),
                    date: String(f.fechaCreacion.prefix(10)),
                    status: uiStatus,
                    footnote: "Saldo: S/ \(String(format: "%.2f", f.saldoPendiente))"
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
                trailingBadge: true,
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(spacing: 14) {
                    if isLoading {
                        ProgressView("Cargando fiados...")
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
                        // Le pasamos los datos "traducidos" a tu componente original
                        ForEach(mappedSections, id: \.store.id) { section in
                            StoreCreditsSectionView(
                                store: section.store,
                                credits: section.credits,
                                isExpanded: expanded.contains(section.store.name),
                                toggle: {
                                    withAnimation(.spring(duration: 0.3)) {
                                        if expanded.contains(section.store.name) {
                                            expanded.remove(section.store.name)
                                        } else {
                                            expanded.insert(section.store.name)
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .fiScreenBackground()
        .task {
            await loadDebts()
        }
    }
    
    private func loadDebts() async {
        isLoading = true
        do {
            fiadosAPI = try await DebtsService.shared.fetchMyDebts()
            // Expandimos la primera tienda por defecto
            if let firstStore = mappedSections.first?.store.name {
                expanded.insert(firstStore)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            fiadosAPI = []
        }
        isLoading = false
    }
}

#Preview {
    CreditsView().environment(AppRouter())
}
