import SwiftUI
import AVFoundation

struct LinkStoreScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onStoreLinked: ((String) -> Void)?

    @State private var torchIsOn = false
    @State private var hasDetectedCode = false
    @State private var validToken: String? = nil
    @State private var storeInfo: TiendaDetalleQR? = nil
    @State private var isAlreadyLinked = false
    @State private var isLoadingInfo = false
    @State private var isLinking = false
    @State private var linkSuccessMessage: String? = nil
    @State private var errorMessage: String? = nil
    @State private var cameraPermission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var laserOffset: CGFloat = -110
    @State private var scanResetTrigger = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if cameraPermission == .denied || cameraPermission == .restricted {
                permissionDeniedView
            } else {
                QRScannerView(
                    torchIsOn: torchIsOn,
                    resetTrigger: scanResetTrigger,
                    onCodeScanned: { code in
                        handleScannedCode(code)
                    },
                    onError: { err in
                        errorMessage = "No se pudo iniciar la cámara: \(err)"
                        hasDetectedCode = true
                    }
                )
                .ignoresSafeArea()

                #if !targetEnvironment(simulator)
                scannerOverlay
                #endif
            }

            VStack {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                Spacer()
            }

            if hasDetectedCode {
                storeDetectedCard
            }
        }
        .onAppear {
            checkCameraPermission()
            startLaserAnimation()
        }
    }

    // MARK: - Barra Superior
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Vincular Tienda")
                .font(.poppins(17, .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                torchIsOn.toggle()
            } label: {
                Image(systemName: torchIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(torchIsOn ? Color.fiGold : .white.opacity(0.85))
                    .padding(8)
                    .background(Circle().fill(.white.opacity(0.15)))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Overlay de Enfoque Láser
    private var scannerOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.fiTeal, lineWidth: 3)
                    .frame(width: 260, height: 260)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.04)))

                if !hasDetectedCode {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color.fiTeal, Color.fiTealSoft, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 240, height: 3)
                        .offset(y: laserOffset)
                        .shadow(color: Color.fiTeal, radius: 8)
                }
            }

            Text("Apunta al código QR del tendero para vincularte")
                .font(.poppins(14, .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Tarjeta de Resultado
    private var storeDetectedCard: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                if let success = linkSuccessMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.fiTeal)
                        Text(success)
                            .font(.poppins(17, .semibold))
                            .foregroundStyle(Color.fiTextPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 16)
                } else if isLoadingInfo {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(Color.fiTeal)
                        Text("Verificando tienda...")
                            .font(.poppins(14, .medium))
                            .foregroundStyle(Color.fiTextSecondary)
                    }
                    .padding(.vertical, 20)
                } else if let err = errorMessage, storeInfo == nil {
                    // Estado de error en QR inválido o falla al consultar tienda
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.fiDanger)

                        Text(err)
                            .font(.poppins(14, .medium))
                            .foregroundStyle(Color.fiTextPrimary)
                            .multilineTextAlignment(.center)

                        Button {
                            resetScanner()
                        } label: {
                            Text("Escanear otro código")
                                .font(.poppins(14, .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Color.fiTeal))
                        }
                        .padding(.top, 4)
                    }
                } else if let store = storeInfo, let token = validToken {
                    // Información válida de la Tienda
                    HStack(spacing: 14) {
                        storeAvatar(urlString: store.imagenUrl)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(store.nombre)
                                .font(.poppins(17, .semibold))
                                .foregroundStyle(Color.fiTextPrimary)

                            if let dir = store.direccion, !dir.isEmpty {
                                Text(dir)
                                    .font(.poppins(12))
                                    .foregroundStyle(Color.fiTextSecondary)
                                    .lineLimit(1)
                            }

                            if isAlreadyLinked {
                                StatusBadge(text: "Ya vinculado", icon: "checkmark.circle.fill")
                                    .padding(.top, 2)
                            }
                        }

                        Spacer()
                    }

                    if let err = errorMessage {
                        Text(err)
                            .font(.poppins(13))
                            .foregroundStyle(Color.fiDanger)
                            .multilineTextAlignment(.center)
                    } else if isAlreadyLinked {
                        Text("Ya te encuentras vinculado a esta tienda. Puedes consultar tus fiados y registrar pagos.")
                            .font(.poppins(13))
                            .foregroundStyle(Color.fiTextSecondary)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("¿Deseas vincular tu cuenta con esta tienda para solicitar fiados y realizar tus pagos?")
                            .font(.poppins(13))
                            .foregroundStyle(Color.fiTextSecondary)
                            .multilineTextAlignment(.leading)
                    }

                    VStack(spacing: 10) {
                        if isAlreadyLinked {
                            FiButton(title: "Entendido", style: .accent) {
                                dismiss()
                            }
                        } else {
                            FiButton(
                                title: isLinking ? "Vinculando..." : "Vincular con la tienda",
                                style: .accent,
                                icon: "link.badge.plus",
                                isEnabled: !isLinking
                            ) {
                                Task {
                                    await performLinkStore(token: token)
                                }
                            }
                        }

                        Button {
                            resetScanner()
                        } label: {
                            Text("Escanear otro código")
                                .font(.poppins(14, .semibold))
                                .foregroundStyle(Color.fiTeal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.3), radius: 20, y: -4)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Estado de Permiso Denegado
    private var permissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.6))

            Text("Acceso a la cámara requerido")
                .font(.poppins(18, .semibold))
                .foregroundStyle(.white)

            Text("Para vincular una tienda, permite el acceso a la cámara en Ajustes.")
                .font(.poppins(14))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Abrir Ajustes")
                    .font(.poppins(15, .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(.white))
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Avatar de Tienda
    @ViewBuilder
    private func storeAvatar(urlString: String?) -> some View {
        if let urlString, !urlString.isEmpty, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                } else if phase.error != nil {
                    defaultStoreIcon
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.fiTealSoft)
                            .frame(width: 52, height: 52)
                        ProgressView()
                            .tint(Color.fiTeal)
                    }
                }
            }
        } else {
            defaultStoreIcon
        }
    }

    private var defaultStoreIcon: some View {
        ZStack {
            Circle()
                .fill(Color.fiTealSoft)
                .frame(width: 52, height: 52)
            Image(systemName: "storefront.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.fiTeal)
        }
    }

    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermission = status
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraPermission = granted ? .authorized : .denied
                }
            }
        }
    }

    private func handleScannedCode(_ code: String) {
        guard !hasDetectedCode else { return }

        guard let token = StoreLinkService.shared.extractToken(from: code) else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                self.hasDetectedCode = true
                self.validToken = nil
                self.storeInfo = nil
                self.errorMessage = "El código escaneado no corresponde a un QR válido de tienda."
            }
            return
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.hasDetectedCode = true
            self.validToken = token
            self.isLoadingInfo = true
            self.errorMessage = nil
        }

        Task {
            do {
                let result = try await StoreLinkService.shared.fetchStoreInfo(token: token)
                await MainActor.run {
                    self.storeInfo = result.tienda
                    self.isAlreadyLinked = result.yaVinculado
                    self.isLoadingInfo = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingInfo = false
                    self.storeInfo = nil
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func performLinkStore(token: String) async {
        isLinking = true
        errorMessage = nil

        do {
            let result = try await StoreLinkService.shared.linkStore(token: token)
            await MainActor.run {
                self.isLinking = false
                self.linkSuccessMessage = result.msg
                let storeName = result.tienda?.nombre ?? storeInfo?.nombre ?? "la tienda"

                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onStoreLinked?(storeName)
            }

            try? await Task.sleep(for: .seconds(1.4))
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                self.isLinking = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func resetScanner() {
        withAnimation {
            hasDetectedCode = false
            validToken = nil
            storeInfo = nil
            isAlreadyLinked = false
            isLoadingInfo = false
            isLinking = false
            linkSuccessMessage = nil
            errorMessage = nil
        }
        scanResetTrigger += 1
        laserOffset = -110
        DispatchQueue.main.async {
            startLaserAnimation()
        }
    }

    private func startLaserAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            laserOffset = 110
        }
    }
}

#Preview {
    LinkStoreScannerSheet()
}

