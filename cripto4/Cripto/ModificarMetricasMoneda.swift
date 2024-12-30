import SwiftUI

// Vista para modificar las métricas de una criptomoneda
struct ModificarMetricasMonedaView: View {
    // Referencias al entorno para cerrar la vista
    @Environment(\.dismiss) var dismiss
    // Objeto observado que representa la criptomoneda a modificar
    @ObservedObject var moneda: Moneda
    // Contexto del modelo para guardar cambios en la base de datos
    @Environment(\.modelContext) var context

    // Propiedades para manejar los datos de la interfaz
    @State private var nombre: String
    @State private var valor: String
    @State private var unidadDeMedida: String
    @State private var mostrarConfirmacion: Bool = false // Estado para mostrar confirmación

    // Opciones para el Picker (unidades de medida)
    private let unidades = ["USD", "EUR"]

    // Inicializador para establecer los valores iniciales basados en la criptomoneda
    init(moneda: Moneda) {
        _moneda = ObservedObject(wrappedValue: moneda)
        _nombre = State(initialValue: moneda.name)
        _valor = State(initialValue: "\(moneda.priceUSD)")
        _unidadDeMedida = State(initialValue: "USD") // Valor inicial ajustable
    }

    var body: some View {
        // Vista de navegación para contener la vista en una estructura jerárquica
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Sección de edición para modificar los datos de la criptomoneda
                    VStack(alignment: .leading, spacing: 15) {
                        // Título de la sección
                        Label("Modificar Métricas", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)

                        // Campos de texto para editar el nombre, valor y unidad de medida
                        Group {
                            // Campo de texto para el nombre de la criptomoneda
                            HStack {
                                Image(systemName: "textformat.abc")
                                    .foregroundColor(.gray)
                                TextField("Nombre", text: $nombre)
                                    .autocapitalization(.words) // Capitaliza las palabras
                                    .textFieldStyle(.roundedBorder) // Estilo de borde redondeado
                            }

                            // Campo de texto para el valor de la criptomoneda
                            HStack {
                                Image(systemName: "number.circle")
                                    .foregroundColor(.gray)
                                TextField("Valor", text: $valor)
                                    .keyboardType(.decimalPad) // Teclado para ingresar números decimales
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: valor) {
                                        // Validar si el valor es un número válido
                                        validarNumero(&valor)
                                    }
                            }

                            // Picker para seleccionar la unidad de medida (USD o EUR)
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.gray)
                                Picker("Unidad de Medida", selection: $unidadDeMedida) {
                                    ForEach(unidades, id: \.self) { unidad in
                                        Text(unidad)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle()) // Estilo Segmentado
                                .onChange(of: unidadDeMedida) { nuevaUnidad in
                                    // Actualizar el valor cuando se cambia la unidad
                                    actualizarValor(según: nuevaUnidad)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6)) // Color de fondo para la sección
                    .cornerRadius(12) // Bordes redondeados para el fondo
                }
                .padding()
            }
            .navigationTitle("Modificar Métricas") // Título de la vista
            .toolbar {
                // Botón de confirmación para guardar cambios
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { mostrarConfirmacion = true }) {
                        Label("Guardar", systemImage: "checkmark.circle")
                            .foregroundColor(.green) // Color verde para el ícono
                    }
                }

                // Botón para cancelar y cerrar la vista
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Label("Cancelar", systemImage: "xmark.circle")
                            .foregroundColor(.red) // Color rojo para el ícono de cancelar
                    }
                }
            }
            // Alerta de confirmación cuando se guardan los cambios
            .alert("Cambios guardados", isPresented: $mostrarConfirmacion) {
                Button("Aceptar") {
                    guardarCambios() // Llamada para guardar los cambios
                }
            } message: {
                Text("Los cambios se han guardado correctamente.") // Mensaje de confirmación
            }
        }
    }

    // Función para guardar los cambios en la criptomoneda
    private func guardarCambios() {
        // Intentamos convertir el valor ingresado en un número decimal
        guard let valorNumerico = Double(valor) else {
            print("Error: El valor no es un número válido.") // Si no es un número válido, se muestra un mensaje
            return
        }

        // Actualizamos los valores de la criptomoneda
        moneda.name = nombre
        moneda.priceUSD = unidadDeMedida == "USD" ? valorNumerico : moneda.priceUSD
        moneda.priceEUR = unidadDeMedida == "EUR" ? valorNumerico : moneda.priceEUR
        moneda.symbol = unidadDeMedida

        // Intentamos guardar los cambios en el contexto del modelo
        do {
            try context.save()
            dismiss() // Cerramos la vista al guardar
        } catch {
            print("Error al guardar los cambios: \(error)") // Si ocurre un error, se imprime un mensaje
        }
    }

    // Función para actualizar el valor mostrado según la unidad seleccionada (USD o EUR)
    private func actualizarValor(según unidad: String) {
        if unidad == "USD" {
            valor = "\(moneda.priceUSD)"
        } else if unidad == "EUR" {
            valor = "\(moneda.priceEUR)"
        }
    }

    // Función para validar que el valor ingresado sea un número válido
    private func validarNumero(_ value: inout String) {
        // Filtra todos los caracteres que no sean números o puntos decimales
        let filtered = value.filter { "0123456789.".contains($0) }
        if filtered != value {
            value = filtered // Actualiza el valor con solo los caracteres válidos
        }
    }
}

