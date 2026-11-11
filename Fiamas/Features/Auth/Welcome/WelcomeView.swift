import SwiftUI

enum AuthSheetMode: Equatable {
    case welcome
    case login
    case register(qrCode: String?)
}

struct WelcomeView: View {
    @Environment(AppRouter.self) private var router
    @State private var showWhatsAppSheet = false
    @State private var isShowingScanner = false
    
    // Estado del panel desplegable (Welcome / Login / Register)
    @State private var sheetMode: AuthSheetMode = .welcome
    @State private var dragOffsetY: CGFloat = 0

    // Color del fondo base según la tarjeta actual
    private var baseBackgroundColor: Color {
        switch sheetMode {
        case .welcome:
            return Color(red: 0.09, green: 0.58, blue: 0.55)
        case .login, .register:
            return .white
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            let safeTop = geometry.safeAreaInsets.top
            
            // Altura base del header según la pantalla activa
            let baseHeaderHeight: CGFloat = switch sheetMode {
            case .welcome: screenHeight * 0.44
            case .login: screenHeight * 0.40
            case .register: screenHeight * 0.22
            }
            
            // La altura real del header crece dinámicamente si el usuario arrastra hacia abajo (solo en login/register)
            let currentHeaderHeight = max(baseHeaderHeight, baseHeaderHeight + dragOffsetY)
            
            ZStack(alignment: .top) {
                // MARK: - 1. Fondo base unificado del color de la tarjeta
                baseBackgroundColor
                    .ignoresSafeArea()
                
                // MARK: - 2. Sección Superior (Imagen de Fondo y Header)
                ZStack(alignment: .top) {
                    Image("Fondo-Fiamas")
                        .resizable()
                        .scaledToFill()
                        .offset(y: 18)
                        .frame(width: screenWidth, height: currentHeaderHeight + 40, alignment: .top)
                        .clipped()
                    
                    // Íconos superiores (Logo y WhatsApp)
                    HStack(alignment: .center) {
                        Image("logo-completo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 38)
                        
                        Spacer()
                        
                        Button(action: {
                            showWhatsAppSheet = true
                        }) {
                            Image("whatsapp")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 42, height: 42)
                                .shadow(radius: 2)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, max(safeTop, 48) + 12)
                }
                .frame(width: screenWidth, height: currentHeaderHeight)
                .ignoresSafeArea(edges: .top)
                
                // MARK: - 3. Tarjeta Deslizable / Bottom Sheet
                VStack(spacing: 0) {
                    Spacer(minLength: currentHeaderHeight - 20)
                    
                    VStack(spacing: 0) {
                        // Indicador de arrastre (Pill Handle) - solo en Login y Registro
                        if sheetMode != .welcome {
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 38, height: 5)
                                .padding(.top, 10)
                                .padding(.bottom, 6)
                        }
                        
                        // Contenido dinámico del sheet
                        switch sheetMode {
                        case .welcome:
                            welcomeSheetContent(screenHeight: screenHeight)
                        case .login:
                            LoginView(
                                onSwitchToRegister: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        sheetMode = .register(qrCode: nil)
                                    }
                                },
                                onDismiss: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        sheetMode = .welcome
                                    }
                                }
                            )
                        case .register(let qrCode):
                            RegisterView(
                                qrCode: qrCode,
                                onSwitchToLogin: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        sheetMode = .login
                                    }
                                },
                                onDismiss: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        sheetMode = .welcome
                                    }
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)
                            .fill(sheetMode == .welcome ? Color(red: 0.09, green: 0.58, blue: 0.55) : Color.white)
                            .shadow(color: .black.opacity(0.12), radius: 10, y: -4)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard sheetMode != .welcome else { return }
                                if value.translation.height > 0 {
                                    dragOffsetY = value.translation.height
                                }
                            }
                            .onEnded { value in
                                guard sheetMode != .welcome else { return }
                                if value.translation.height > 110 || value.predictedEndTranslation.height > 200 {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        sheetMode = .welcome
                                        dragOffsetY = 0
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        dragOffsetY = 0
                                    }
                                }
                            }
                    )
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: sheetMode)
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $isShowingScanner) {
            QRScannerSheet(
                onNavigateToRegister: { code in
                    isShowingScanner = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        sheetMode = .register(qrCode: code)
                    }
                }
            )
        }
        .confirmationDialog("Soporte por WhatsApp", isPresented: $showWhatsAppSheet, titleVisibility: .visible) {
            Button("Abrir WhatsApp") {
                openWhatsApp()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("¿Deseas abrir la aplicación de WhatsApp para contactar a soporte?")
        }
    }

    @ViewBuilder
    private func welcomeSheetContent(screenHeight: CGFloat) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                Spacer(minLength: 16)
                
                Text("BIENVENIDO")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                
                Text("¡Nos alegra tenerte por aquí!")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 4)
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        sheetMode = .login
                    }
                }) {
                    Text("Inicia sesión")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.90, green: 0.68, blue: 0.25))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                
                Text("¿No tienes cuenta?")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        sheetMode = .register(qrCode: nil)
                    }
                }) {
                    Text("Registrate")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.90, green: 0.68, blue: 0.25))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 16)
                
                Button(action: {
                    isShowingScanner = true
                }) {
                    VStack(spacing: 10) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 72, weight: .regular))
                            .foregroundColor(.black)
                        
                        Text("Escanear QR del Tendero")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer(minLength: 28)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    private func openWhatsApp() {
        let phoneNumber = "+51999999999"
        if let url = URL(string: "https://wa.me/\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppRouter())
}
