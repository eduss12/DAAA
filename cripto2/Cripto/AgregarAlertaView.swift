import SwiftUI
import SwiftData
import UserNotifications

struct AgregarAlertaView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var cryptoName: String = ""
    @State private var cryptoSymbol: String = ""
    @State private var isPriceAbove: Bool = true // true: subida, false: bajada
    @State private var targetPrice: String = ""

    @State private var currentPrice: Double? // Precio actual de la criptomoneda
    @State private var timer: Timer? // Temporizador

    var onSave: (() -> Void)? // Callback para recargar datos después de guardar

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Criptomoneda")) {
                    TextField("Nombre", text: $cryptoName)
                    TextField("Símbolo", text: $cryptoSymbol)
                }

                Section(header: Text("Configuración de la Alerta")) {
                    Picker("Tipo de alerta", selection: $isPriceAbove) {
                        Text("Subida de precio").tag(true)
                        Text("Bajada de precio").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    TextField("Precio objetivo", text: $targetPrice)
                        .keyboardType(.decimalPad)

                    if let price = currentPrice {
                        Text("Precio actual: \(price, specifier: "%.2f") USD")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Nueva Alerta")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        solicitarPermisosNotificaciones()
                        guardarAlerta()
                        iniciarTemporizador()
                    }
                    .disabled(!datosValidos())
                }
            }
        }
        .onDisappear {
            detenerTemporizador()
        }
    }

    private func datosValidos() -> Bool {
        return !cryptoName.isEmpty  && !cryptoSymbol.isEmpty && Double(targetPrice) != nil
    }

    private func guardarAlerta() {
        guard let price = Double(targetPrice) else { return }

        let nuevaAlerta = Alerta(
            cryptoName: cryptoName,
            cryptoSymbol: cryptoSymbol,
            isPriceAbove: isPriceAbove,
            targetPrice: price
        )

        context.insert(nuevaAlerta)

        do {
            try context.save()
            onSave?()
            dismiss()
        } catch {
            print("Error al guardar la alerta: \(error)")
        }
    }

    private func iniciarTemporizador() {
        detenerTemporizador() // Asegurarse de que no haya otro temporizador corriendo
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            consultarPrecio()
        }
    }

    private func detenerTemporizador() {
        timer?.invalidate()
        timer = nil
    }

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
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let cryptoData = json[cryptoName.lowercased()] as? [String: Any],
                   let price = cryptoData["usd"] as? Double {
                    DispatchQueue.main.async {
                        self.currentPrice = price
                        self.verificarPrecioActual(price: price)
                    }
                } else {
                    print("Respuesta inesperada de la API")
                }
            } catch {
                print("Error al procesar el JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }


    private func verificarPrecioActual(price: Double) {
        guard let targetPrice = Double(targetPrice), !targetPrice.isNaN else {
                print("Precio objetivo no válido: \(targetPrice)")
                return
            }
        if !price.isNaN{
            if isPriceAbove && price >= targetPrice {
                enviarNotificacion(titulo: "¡Subida de precio!",
                                   mensaje: "El precio de \(cryptoName) ha subido a \(price) USD")
            } else if !isPriceAbove && price <= targetPrice {
                enviarNotificacion(titulo: "¡Bajada de precio!",
                                   mensaje: "El precio de \(cryptoName) ha bajado a \(price) USD")
            } else if price == targetPrice {
                enviarNotificacion(titulo: "Precio actual",
                                   mensaje: "El precio de \(cryptoName) está en \(price) USD")
            }
        } else {
            print("precio no valido")
        }
    }

    private func enviarNotificacion(titulo: String, mensaje: String) {
        let content = UNMutableNotificationContent()
        content.title = titulo
        content.body = mensaje
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al enviar la notificación: \(error)")
            }
        }
    }

    private func solicitarPermisosNotificaciones() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error al solicitar permisos: \(error)")
            }
            if !granted {
                print("Permisos de notificaciones denegados.")
            }
        }
    }
}

#Preview {
    AgregarAlertaView()
}

