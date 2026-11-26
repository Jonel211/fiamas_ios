import SwiftUI
import UIKit

/// Archivo temporal listo para compartir.
struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

/// Envuelve UIActivityViewController para compartir archivos desde SwiftUI.
struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
