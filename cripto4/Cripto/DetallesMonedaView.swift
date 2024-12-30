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
            
            ScrollView {
                
                VStack(spacing: 25) {
                    // Detalles Criptomoneda
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalles de la Criptomoneda")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nombre: \(moneda.name)")
                            Text("Símbolo: \(moneda.symbol)")
                            Text("Precio Actual (USD): $\(moneda.priceUSD, specifier: "%.2f")")
                            Text("Precio Actual (EUR): €\(moneda.priceEUR, specifier: "%.2f")")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 8)
                    }

                    // Estadísticas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Estadísticas")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Variación 24h: \(moneda.cambio24h, specifier: "%.2f")%")
                            Text("Volumen de Mercado: \(moneda.volumen, specifier: "%.2f")")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 8)
                    }

                    // Mensaje de error
                    if let mensajeError = mensajeError {
                        Text(mensajeError)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // Histórico de Precios
                    VStack {
                        Text("Histórico de Precios")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.bottom, 10)

                        if cargandoGrafico {
                            ProgressView("Cargando gráfico...")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 8)
                                .frame(maxWidth: .infinity)
                        } else {
                            //Realizamos un gráfico en el que se detalla la variacion del precio a lo largo del tiempo, para ello usamos Chart
                            Chart(precioHistorico) { data in
                                LineMark(
                                    x: .value("Fecha", data.fecha),
                                    y: .value("Precio", data.precio)
                                )
                                .foregroundStyle(.blue)
                            }
                            .chartYScale(domain: .automatic)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 8)
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // Botones para las acciones
                    HStack(spacing: 20) {
                        Button("Modificar Métricas") {
                            mostrarModificarMetricas = true // Cambiar el estado para mostrar el sheet
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)

                        Button("Eliminar Criptomoneda") {
                            eliminarMoneda()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 8)
                }
                .padding(.horizontal)
            }
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


