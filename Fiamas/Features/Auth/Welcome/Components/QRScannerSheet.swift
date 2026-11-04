import SwiftUI
import AVFoundation

struct QRScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onCodeScanned: ((String) -> Void)?
    var onNavigateToRegister: ((String) -> Void)?

    @State private var torchIsOn = false
    @State private var scannedCode: String? = nil
    @State private var cameraPermission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var laserOffset: CGFloat = -110
    @State private var showCopiedAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if cameraPermission == .denied || cameraPermission == .restricted {
                permissionDeniedView
            } else {
                // Vista de cámara
                QRScannerView(
                    torchIsOn: torchIsOn,
                    onCodeScanned: { code in
                        handleScannedCode(code)
                    },
                    onError: { err in
                        print("Scanner error: \(err)")
                    }
                )
                .ignoresSafeArea()

                // Overlay con recuadro y máscara oscura
                scannerOverlay
            }

            // Barra superior de controles
            VStack {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                Spacer()
            }

            // Modal inferior con el resultado escaneado
            if let code = scannedCode {
                scannedResultCard(code: code)
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

            Text("Escanear QR")
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

    // MARK: - Máscara y Cuadro de Enfoque
    private var scannerOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                // Marco con bordes esquineros
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.fiTeal, lineWidth: 3)
                    .frame(width: 260, height: 260)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.04)))

                // Línea láser animada de escaneo
                if scannedCode == nil {
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

            Text("Apunta la cámara hacia el código QR del tendero")
                .font(.poppins(14, .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Tarjeta de Resultado Escaneado
    private func scannedResultCard(code: String) -> some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.fiTeal)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("¡Código detectado!")
                            .font(.poppins(16, .semibold))
                            .foregroundStyle(Color.fiTextPrimary)
                        Text("Tienda vinculada correctamente")
                            .font(.poppins(12))
                            .foregroundStyle(Color.fiTextSecondary)
                    }
                    Spacer()
                }

                // Código o enlace
                HStack {
                    Text(code)
                        .font(.poppins(13, .medium))
                        .foregroundStyle(Color.fiTextPrimary)
                        .lineLimit(2)
                    Spacer()
                    Button {
                        UIPasteboard.general.string = code
                        showCopiedAlert = true
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.fiTeal)
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.fiSkySoft))

                // Botones de acción
                VStack(spacing: 10) {
                    FiButton(title: "Registrarme en esta tienda", style: .accent, icon: "person.badge.plus") {
                        dismiss()
                        onNavigateToRegister?(code)
                    }

                    Button {
                        scannedCode = nil
                        startLaserAnimation()
                    } label: {
                        Text("Escanear otro código")
                            .font(.poppins(14, .semibold))
                            .foregroundStyle(Color.fiTeal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
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
        .alert("Copiado", isPresented: $showCopiedAlert) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text("El código fue copiado al portapapeles.")
        }
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

            Text("Para escanear el código QR del tendero, permite el acceso a la cámara en Ajustes.")
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
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.scannedCode = code
        }
        onCodeScanned?(code)
    }

    private func startLaserAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            laserOffset = 110
        }
    }
}

#Preview {
    QRScannerSheet()
}

