import SwiftUI

/// iOS-pagos
struct PaymentsView: View {
    @Environment(AppRouter.self) private var router
    @State private var selectedStore = "Todas las tiendas"
    @State private var month = "septiembre 2026"

    private let groups = PaymentGroup.samples
    private var stores: [String] {
        ["Todas las tiendas"] + groups.flatMap { $0.payments.map(\.store) }
    }

    var body: some View {
        VStack(spacing: 0) {
            FiHeader(
                title: "Pagos",
                onLeading: { router.push(.menu) },
                onTrailing: { router.push(.notifications) }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    filters
                        .padding(.bottom, 26)

                    ForEach(groups) { group in
                        Text(group.title)
                            .font(.poppins(14, .medium))
                            .padding(.leading, 10)
                            .padding(.bottom, 6)
                        VStack(spacing: 20) {
                            ForEach(group.payments) { payment in
                                Button { router.push(.paymentDetail) } label: {
                                    PaymentRowView(payment: payment)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 26)
            }
        }
    }

    private var filters: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tienda").font(.poppins(13, .semibold))
                Menu {
                    ForEach(stores, id: \.self) { s in
                        Button(s) { selectedStore = s }
                    }
                } label: {
                    HStack {
                        Text(selectedStore).lineLimit(1)
                        Spacer(minLength: 4)
                        Text("v")
                    }
                    .font(.poppins(10))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 6)
                    .frame(width: 118, height: 34)
                    .cardStyle(cornerRadius: 6, border: .fiCardBorder)
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                Text("Mes").font(.poppins(10, .semibold)).padding(.leading, 8)
                Text(month)
                    .font(.poppins(10))
                    .frame(width: 110, height: 34)
                    .cardStyle(cornerRadius: 6, border: .fiCardBorder)
            }
        }
    }
}

#Preview {
    PaymentsView().environment(AppRouter())
}
