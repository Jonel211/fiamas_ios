import SwiftUI

struct WelcomeView: View {
    @Environment(AppRouter.self) private var router
    @State private var showWhatsAppSheet = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            let safeTop = geometry.safeAreaInsets.top
            
            // La cabecera ocupa el 42% de la altura total de la pantalla
            let headerHeight = screenHeight * 0.42
            
            VStack(spacing: 0) {
                // MARK: - Sección Superior (Imagen de Fondo y Header)
                ZStack(alignment: .top) {
                    // Imagen de Fondo (se extiende 40pt por debajo del corte para la tarjeta)
                    Image("Fondo-Fiamas")
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth, height: headerHeight + 40)
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
                    // Ubica los íconos justo debajo de la barra de estado / Isla Dinámica
                    .padding(.top, max(safeTop, 44) + 8)
                }
                .frame(width: screenWidth, height: headerHeight)
                
                // MARK: - Tarjeta Inferior
                ZStack {
                    Color(red: 0.09, green: 0.58, blue: 0.55)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            Spacer(minLength: 12)
                            
                            Text("BIENVENIDO")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(.white)
                            
                            Text("¡Nos alegra tenerte por aquí!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.bottom, 4)
                            
                            // Botón: Inicia sesión
                            Button(action: {
                                router.push(.login)
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
                            
                            // Texto pre-registro
                            Text("¿No tienes cuenta?")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.top, 4)
                            
                            // Botón: Regístrate
                            Button(action: {
                                router.push(.register)
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
                            
                            // MARK: - Sección Escanear QR
                            Button(action: {
                                // Acción para escanear QR
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
                            
                            Spacer(minLength: 24)
                        }
                        .frame(maxWidth: 500)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: screenHeight * 0.58 - 20)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
                .clipShape(.rect(topLeadingRadius: 28, topTrailingRadius: 28))
                .padding(.top, -24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea()
        // Desplegable tipo Intent / Sheet para WhatsApp
        .confirmationDialog("Soporte por WhatsApp", isPresented: $showWhatsAppSheet, titleVisibility: .visible) {
            Button("Abrir WhatsApp") {
                openWhatsApp()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("¿Deseas abrir la aplicación de WhatsApp para contactar a soporte?")
        }
    }
    
    // Función para abrir la URL de WhatsApp
    private func openWhatsApp() {
        let phoneNumber = "+51999999999" // Número oficial
        if let url = URL(string: "https://wa.me/\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppRouter())
}
