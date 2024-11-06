import SwiftUI
import SwiftData

struct ConfiguracionView: View {
    @State private var ritmoLectura = UserDefaults.standard.double(forKey: "RitmoLectura")
    
    // Datos del usuario
    @State private var nombreUsuario = UserDefaults.standard.string(forKey: "NombreUsuario") ?? "Usuario"
    @State private var correoUsuario = UserDefaults.standard.string(forKey: "CorreoUsuario") ?? "correo@ejemplo.com"
    
    // Preferencias de notificaciones
    @State private var notificacionesActivadas = UserDefaults.standard.bool(forKey: "NotificacionesActivadas")
    
    // Configuración de tema
    @Environment(\.colorScheme) var colorScheme
    @State private var temaOscuro = UserDefaults.standard.bool(forKey: "TemaOscuro")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Encabezado de la pantalla
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                    Text("Configuración")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top)
                
                // Configuración de ritmo de lectura
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ritmo de Lectura")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                        
                        Stepper(" \(Int(ritmoLectura)) páginas/min", value: $ritmoLectura, in: 1...100)
                            .onChange(of: ritmoLectura) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "RitmoLectura")
                            }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()

                // Configuración de datos del usuario
                VStack(alignment: .leading, spacing: 10) {
                    Text("Datos del Usuario")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    TextField("Nombre", text: $nombreUsuario)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: nombreUsuario) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "NombreUsuario")
                        }

                    TextField("Correo Electrónico", text: $correoUsuario)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .onChange(of: correoUsuario) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "CorreoUsuario")
                        }
                }
                .padding()

                // Configuración de notificaciones
                VStack(alignment: .leading, spacing: 10) {
                    Text("Notificaciones")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Toggle("Activar Notificaciones", isOn: $notificacionesActivadas)
                        .onChange(of: notificacionesActivadas) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "NotificacionesActivadas")
                        }
                }
                .padding()

                // Configuración de tema
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tema de la Aplicación")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Toggle("Modo Oscuro", isOn: $temaOscuro)
                        .onChange(of: temaOscuro) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "TemaOscuro")
                            // Para aplicar el tema oscuro, puedes configurar un valor global
                            UIApplication.shared.windows.first?.rootViewController?.overrideUserInterfaceStyle = newValue ? .dark : .light
                        }
                }
                .padding()

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ConfiguracionView()
}

