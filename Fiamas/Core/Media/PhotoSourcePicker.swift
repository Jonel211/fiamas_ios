import PhotosUI
import SwiftUI

/// Muestra las opciones "Elegir de la galería", "Tomar foto" y "Eliminar foto",
/// y devuelve la imagen elegida.
private struct PhotoSourcePicker: ViewModifier {
    @Binding var isPresented: Bool
    let canRemove: Bool
    let onPick: (UIImage) -> Void
    let onRemove: () -> Void

    @State private var isShowingLibrary = false
    @State private var isShowingCamera = false
    @State private var libraryItem: PhotosPickerItem?

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func body(content: Content) -> some View {
        content
            .confirmationDialog("Foto de perfil", isPresented: $isPresented, titleVisibility: .visible) {
                Button("Elegir de la galería") { isShowingLibrary = true }
                if isCameraAvailable {
                    Button("Tomar foto") { isShowingCamera = true }
                }
                if canRemove {
                    Button("Eliminar foto", role: .destructive, action: onRemove)
                }
            }
            .photosPicker(isPresented: $isShowingLibrary, selection: $libraryItem, matching: .images)
            .onChange(of: libraryItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        onPick(image)
                    }
                    libraryItem = nil
                }
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraPicker(onCapture: onPick)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    func photoSourcePicker(isPresented: Binding<Bool>, canRemove: Bool,
                           onPick: @escaping (UIImage) -> Void,
                           onRemove: @escaping () -> Void) -> some View {
        modifier(PhotoSourcePicker(isPresented: isPresented, canRemove: canRemove, onPick: onPick, onRemove: onRemove))
    }
}
