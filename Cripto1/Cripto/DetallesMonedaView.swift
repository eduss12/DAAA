import SwiftUI
import Charts

struct DetallesMonedaView: View {
    @Environment(\.dismiss) var dismiss // Volver a la lista principal
    @Environment(\.modelContext) private var modelContext
    @State private var precioHistorico: [PrecioHistorico] = [] // Datos para el gráfico
    @State private var cargandoGrafico: Bool = true
    @State private var mensajeError: String? = nil
    @State private var mostrarModificarMetricas = false // Control para mostrar la vista de modificación

    let moneda: Moneda // Detalles de la moneda seleccionada

    private let service = CryptoService()

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Detalles de la Criptomoneda")) {
                    Text("Nombre: \(moneda.name)")
                    Text("Símbolo: \(moneda.symbol)")
                    Text("Precio Actual (USD): $\(moneda.priceUSD, specifier: "%.2f")")
                    Text("Precio Actual (EUR): €\(moneda.priceEUR, specifier: "%.2f")")
                }

                Section(header: Text("Estadísticas")) {
                    Text("Variación 24h: \(moneda.cambio24h ?? 0, specifier: "%.2f")%")
                    Text("Volumen de Mercado: \(moneda.volumen ?? 0, specifier: "%.2f")")
                }

                if let mensajeError = mensajeError {
                    Text(mensajeError)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
            }

            Section(header: Text("Histórico de Precios")) {
                if cargandoGrafico {
                    ProgressView("Cargando gráfico...")
                        .padding()
                } else {
                    Chart(precioHistorico) { data in
                        LineMark(
                            x: .value("Fecha", data.fecha),
                            y: .value("Precio", data.precio)
                        )
                        .foregroundStyle(.blue)
                    }
                    .chartYScale(domain: .automatic)
                    .padding()
                }
            }

            Spacer()

            // Botones para las acciones
            HStack {
                Button("Modificar Métricas") {
                    mostrarModificarMetricas = true // Cambiar el estado para mostrar el sheet
                }
                .buttonStyle(.borderedProminent)
                
                Button("Eliminar Criptomoneda") {
                    eliminarMoneda()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding()
        }
        .navigationTitle(moneda.name)
        .onAppear {
            cargarDatosHistoricos()
        }
        .sheet(isPresented: $mostrarModificarMetricas) {
            ModificarMetricasMonedaView(moneda: moneda) // Pasa la moneda seleccionada
        }
    }

    /// Cargar datos históricos de precios
    private func cargarDatosHistoricos() {
        cargandoGrafico = true
        mensajeError = nil

        service.fetchHistoricalPrices(for: moneda.id) { result in
            DispatchQueue.main.async {
                self.cargandoGrafico = false
                switch result {
                case .success(let historico):
                    self.precioHistorico = historico
                case .failure(let error):
                    self.mensajeError = "Error al cargar datos históricos: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Eliminar la criptomoneda
    private func eliminarMoneda() {
        modelContext.delete(moneda)
        do {
            try modelContext.save()
            dismiss() // Volver a la lista principal
        } catch {
            mensajeError = "Error al eliminar la moneda: \(error.localizedDescription)"
        }
    }
}

