import SwiftUI
import SwiftData
import UserNotifications

// Vista para agregar una nueva alerta para una criptomoneda
struct AgregarAlertaView: View {
    // Referencias al entorno
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // Propiedades de estado para almacenar los datos de la alerta
    @State private var cryptoName: String = "" // Nombre de la criptomoneda
    @State private var cryptoSymbol: String = "" // Símbolo de la criptomoneda
    @State private var isPriceAbove: Bool = true // Si la alerta es para cuando el precio sube o baja
    @State private var targetPrice: String = "" // Precio objetivo

    // Propiedades para gestionar el precio actual y el temporizador
    @State private var currentPrice: Double?
    @State private var timer: Timer?

    // Callback para notificar cuando se guarda la alerta
    var onSave: (() -> Void)?

    var body: some View {
        // Vista de navegación para envolver la interfaz de usuario
        NavigationStack {
            VStack {
                // Desplazable para los contenidos
                ScrollView {
                    VStack(spacing: 30) {
                        // Sección de Criptomoneda
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Criptomoneda", systemImage: "bitcoinsign.circle")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)

                            VStack(spacing: 10) {
                                // Campo de texto para el nombre de la criptomoneda
                                HStack {
                                    Image(systemName: "textformat.abc")
                                        .foregroundColor(.gray)
                                    TextField("Ejemplo: Bitcoin", text: $cryptoName)
                                        .textFieldStyle(.roundedBorder)
                                }
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )

                                // Campo de texto para el símbolo de la criptomoneda
                                HStack {
                                    Image(systemName: "number")
                                        .foregroundColor(.gray)
                                    TextField("Símbolo (Ej: BTC)", text: $cryptoSymbol)
                                        .textFieldStyle(.roundedBorder)
                                }
                                .padding(.horizontal)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                        // Sección de configuración de la alerta
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Configuración de la Alerta", systemImage: "bell.badge")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)

                            // Picker para seleccionar el tipo de alerta (subida o bajada de precio)
                            Picker("Tipo de alerta", selection: $isPriceAbove) {
                                Label("Subida de precio", systemImage: "arrow.up.circle")
                                    .tag(true)
                                Label("Bajada de precio", systemImage: "arrow.down.circle")
                                    .tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())

                            // Campo de texto para el precio objetivo
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(.gray)
                                TextField("Precio objetivo", text: $targetPrice)
                                    .keyboardType(.decimalPad) // Tipo de teclado para precios decimales
                                    .textFieldStyle(.roundedBorder)
                            }
                            .padding(.horizontal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                            // Mostrar el precio actual si está disponible
                            if let price = currentPrice {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundColor(.gray)
                                    Text("Precio actual: \(price, specifier: "%.2f") USD")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding()
                }

                // Botones de acción para cancelar o guardar la alerta
                HStack(spacing: 15) {
                    // Botón para cancelar y cerrar la vista
                    Button(action: {
                        dismiss()
                    }) {
                        Label("Cancelar", systemImage: "xmark.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                    }

                    // Botón para guardar la alerta
                    Button(action: {
                        solicitarPermisosNotificaciones()
                        guardarAlerta() // Guardar la alerta
                        iniciarTemporizador() // Iniciar el temporizador para comprobar el precio
                    }) {
                        Label("Guardar", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .disabled(!datosValidos()) // Deshabilitar el botón si los datos no son válidos
                }
                .padding()
            }
            .navigationTitle("Nueva Alerta") // Título de la vista
            .onDisappear {
                detenerTemporizador() // Detener el temporizador cuando la vista desaparece
            }
        }
    }

    // Función para verificar si los datos ingresados son válidos
    private func datosValidos() -> Bool {
        return !cryptoName.isEmpty && !cryptoSymbol.isEmpty && Double(targetPrice) != nil
    }

    // Función para guardar la alerta en el contexto del modelo
    private func guardarAlerta() {
        guard let price = Double(targetPrice) else {
            print("Precio objetivo no válido.")
            return
        }

        // Crear una nueva alerta con los datos ingresados
        let nuevaAlerta = Alerta(
            cryptoName: cryptoName,
            cryptoSymbol: cryptoSymbol,
            isPriceAbove: isPriceAbove,
            targetPrice: price
        )

        // Insertar la alerta en el contexto
        context.insert(nuevaAlerta)

        do {
            try context.save() // Guardar el contexto
            onSave?() // Llamar al callback onSave si se ha guardado
            dismiss() // Cerrar la vista
            print("Alerta guardada exitosamente.")
        } catch {
            print("Error al guardar la alerta: \(error)")
        }
    }

    // Función para iniciar un temporizador para consultar el precio cada 5 minutos
    private func iniciarTemporizador() {
        detenerTemporizador() // Detener cualquier temporizador anterior
        consultarPrecio() // Consultar el precio de la criptomoneda
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.consultarPrecio() // Consultar el precio cada 5 minutos
        }
    }

    // Función para detener el temporizador
    private func detenerTemporizador() {
        timer?.invalidate()
        timer = nil
    }

    // Función para consultar el precio actual de la criptomoneda desde la API de CoinGecko
    private func consultarPrecio() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=\(cryptoName.lowercased())&vs_currencies=usd") else {
            print("URL no válida")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error al consultar el precio: \(error)")
                return
            }

            guard let data = data else {
                print("No se recibieron datos")
                return
            }

            do {
                // Procesar los datos JSON recibidos
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let cryptoData = json[cryptoName.lowercased()] as? [String: Any],
                       let price = cryptoData["usd"] as? Double {
                        DispatchQueue.main.async {
                            self.currentPrice = price
                            self.verificarPrecioActual(price: price)
                        }
                    }
                }
            } catch {
                print("Error al procesar el JSON: \(error.localizedDescription)")
            }
        }
        task.resume() // Iniciar la solicitud
    }

    // Función para verificar si el precio actual cumple con la condición de la alerta
    private func verificarPrecioActual(price: Double) {
        guard let targetPrice = Double(targetPrice) else { return }

        if isPriceAbove && price >= targetPrice {
            enviarNotificacion(titulo: "¡Subida de precio!", mensaje: "El precio de \(cryptoName) ha subido a \(price) USD")
        } else if !isPriceAbove && price <= targetPrice {
            enviarNotificacion(titulo: "¡Bajada de precio!", mensaje: "El precio de \(cryptoName) ha bajado a \(price) USD")
        }
    }

    // Función para enviar una notificación al usuario
    private func enviarNotificacion(titulo: String, mensaje: String) {
        let content = UNMutableNotificationContent()
        content.title = titulo
        content.body = mensaje
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al enviar la notificación: \(error)")
            } else {
                print("Notificación enviada correctamente.")
            }
        }
    }

    // Función para solicitar permisos para enviar notificaciones
    private func solicitarPermisosNotificaciones() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error al solicitar permisos: \(error)")
            }
            if !granted {
                print("Permisos de notificaciones denegados.")
            } else {
                print("Permisos concedidos")
            }
        }
    }
}

#Preview {
    AgregarAlertaView()
}

