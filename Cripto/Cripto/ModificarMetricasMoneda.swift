import SwiftUI

struct ModificarMetricasMonedaView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var moneda: Moneda  // Ahora esta propiedad observa cambios en Moneda
    @Environment(\.modelContext) var context

    @State private var nombre: String
    @State private var simbolo: String
    @State private var precioUSD: String
    @State private var precioEUR: String
    @State private var volumen: String
    @State private var cambio24h: String

    // El inicializador recibe la moneda
    init(moneda: Moneda) {
        _moneda = ObservedObject(wrappedValue: moneda)  // Inicializamos el ObservedObject aquí
        _nombre = State(initialValue: moneda.name)
        _simbolo = State(initialValue: moneda.symbol)
        _precioUSD = State(initialValue: "\(moneda.priceUSD)")
        _precioEUR = State(initialValue: "\(moneda.priceEUR)")
        _volumen = State(initialValue: "\(moneda.volumen ?? 0)")
        _cambio24h = State(initialValue: "\(moneda.cambio24h ?? 0)")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Modificar Métricas")) {
                    TextField("Nombre", text: $nombre)
                    TextField("Símbolo", text: $simbolo)
                    TextField("Precio (USD)", text: $precioUSD)
                        .keyboardType(.decimalPad)
                    TextField("Precio (EUR)", text: $precioEUR)
                        .keyboardType(.decimalPad)
                    TextField("Volumen de Mercado", text: $volumen)
                        .keyboardType(.decimalPad)
                    TextField("Variación 24h (%)", text: $cambio24h)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Modificar \(moneda.name)")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardarCambios()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    /// Guardar los cambios en la moneda
    private func guardarCambios() {
        moneda.name = nombre
        moneda.symbol = simbolo
        moneda.priceUSD = Double(precioUSD) ?? moneda.priceUSD
        moneda.priceEUR = Double(precioEUR) ?? moneda.priceEUR
        moneda.volumen = Double(volumen)
        moneda.cambio24h = Double(cambio24h)

        do {
            try context.save()
            dismiss()
        } catch {
            print("Error al guardar los cambios: \(error)")
        }
    }
}

