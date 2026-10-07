import SwiftUI

struct CreditProgressView: View {
    var used: Int = 140
    var limit: Int = 200
    var width: CGFloat = 125
    var compact: Bool = false

    private var ratio: Double { min(1, Double(used) / Double(max(limit, 1))) }

    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text("Crédito usado: S/\(used)")
                .font(.poppins(compact ? 7 : 8))
                .foregroundStyle(Color.fiTeal)
                .frame(width: width, alignment: compact ? .center : .trailing)
            HStack(spacing: 18) {
                Text("Tu limite").font(.poppins(compact ? 8 : 9))
                Text("S/\(limit)").font(.poppins(compact ? 8 : 9))
            }
            .frame(width: width, alignment: compact ? .center : .trailing)
            ZStack(alignment: .leading) {
                Capsule().stroke(Color.black, lineWidth: 0.7)
                Capsule().fill(Color.fiTeal).frame(width: width * ratio)
            }
            .frame(width: width, height: 7)
            Text("\(Int(ratio * 100))%")
                .font(.poppins(7))
                .foregroundStyle(Color.fiTeal)
                .frame(width: width, alignment: .center)
                .padding(.leading, compact ? 0 : width * 0.3)
        }
    }
}
