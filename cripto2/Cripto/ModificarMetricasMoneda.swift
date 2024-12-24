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
        _volumen = State(initialValue: "\(String(describing: moneda.volumen))")
        _cambio24h = State(initialValue: "\(String(describing: moneda.cambio24h))")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Modificar Métricas")) {
                    TextField("Nombre", text: $nombre)
                        .autocapitalization(.words) // Hacer que el primer carácter de cada palabra se capitalice
                    TextField("Símbolo", text: $simbolo)
                        .autocapitalization(.allCharacters) // Hacer que todo el símbolo esté en mayúsculas
                    TextField("Precio (USD)", text: $precioUSD)
                        .keyboardType(.decimalPad)
                        .onChange(of: precioUSD) {
                            validarNumero(&precioUSD)
                        }
                    TextField("Precio (EUR)", text: $precioEUR)
                        .keyboardType(.decimalPad)
                        .onChange(of: precioEUR) {
                            validarNumero(&precioEUR)
                        }
                    TextField("Volumen de Mercado", text: $volumen)
                        .keyboardType(.decimalPad)
                        .onChange(of: volumen) {
                            validarNumero(&volumen)
                        }
                    TextField("Variación 24h (%)", text: $cambio24h)
                        .keyboardType(.decimalPad)
                        .onChange(of: cambio24h) { 
                            validarNumero(&cambio24h)
                        }
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
        // Verificar si los campos son válidos antes de guardar
        guard let precioUSDVal = Double(precioUSD), let precioEURVal = Double(precioEUR),
              let volumenVal = Double(volumen), let cambio24hVal = Double(cambio24h) else {
            print("Error: Algunos valores no son válidos.")
            return
        }

        // Asignar los valores modificados a la moneda
        moneda.name = nombre
        moneda.symbol = simbolo
        moneda.priceUSD = precioUSDVal
        moneda.priceEUR = precioEURVal
        moneda.volumen = volumenVal
        moneda.cambio24h = cambio24hVal

        // Guardar los cambios en el contexto
        do {
            try context.save()
            dismiss() // Cerrar la vista
        } catch {
            print("Error al guardar los cambios: \(error)")
        }
    }

    // Función para validar que el valor ingresado sea un número válido
    private func validarNumero(_ value: inout String) {
        let filtered = value.filter { "0123456789.".contains($0) }
        if filtered != value {
            value = filtered
        }
    }
}


