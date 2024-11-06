import SwiftUI
import SwiftData

struct AgregarLibroView: View {
    @Environment(\.modelContext) private var context
    @State private var titulo = ""
    @State private var anioPublicacion = ""
    @State private var numeroPaginas = ""
    @State private var precio = ""
    @State private var nombreAutor = ""
    @State private var apellidosAutor = ""
    @State private var estadoLectura = EstadoLectura.noIniciado
    @State private var progresoLectura = 0.0
    @State private var mostrandoAlerta = false

    var body: some View {
        NavigationView {
            Form {
                // Sección de información básica del libro
                Section(header: Text("Información del Libro").font(.headline)) {
                    TextField("Título", text: $titulo)
                        .textFieldStyle(VisualTextFieldStyle(iconName: "book.fill"))
                    
                    TextField("Año de Publicación", text: $anioPublicacion)
                        .keyboardType(.numberPad)
                        .textFieldStyle(VisualTextFieldStyle(iconName: "calendar"))

                    TextField("Número de Páginas", text: $numeroPaginas)
                        .keyboardType(.numberPad)
                        .textFieldStyle(VisualTextFieldStyle(iconName: "number"))

                    TextField("Precio", text: $precio)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(VisualTextFieldStyle(iconName: "tag.fill"))
                }
                
                // Sección de información del autor
                Section(header: Text("Información del Autor").font(.headline)) {
                    TextField("Nombre del Autor", text: $nombreAutor)
                        .textFieldStyle(VisualTextFieldStyle(iconName: "person.fill"))
                    
                    TextField("Apellidos del Autor", text: $apellidosAutor)
                        .textFieldStyle(VisualTextFieldStyle(iconName: "person.2.fill"))
                }
                
                // Sección de estado de lectura
                Section(header: Text("Estado de Lectura").font(.headline)) {
                    Picker("Estado", selection: $estadoLectura) {
                        Text("No Iniciado").tag(EstadoLectura.noIniciado)
                        Text("En Progreso").tag(EstadoLectura.enProgreso)
                        Text("Completado").tag(EstadoLectura.completado)
                    }
                    .pickerStyle(.segmented)
                    
                    // Slider de progreso, solo visible si el estado es "En Progreso"
                    if estadoLectura == .enProgreso {
                        VStack {
                            Slider(value: $progresoLectura, in: 0...100, step: 1)
                            Text("Progreso: \(Int(progresoLectura))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                }
                
                // Botón para guardar el libro
                Section {
                    Button(action: guardarLibro) {
                        HStack {
                            Spacer()
                            Text("Guardar Libro")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .listRowBackground(Color.clear)
                    .alert(isPresented: $mostrandoAlerta) {
                        Alert(title: Text("Libro Guardado"), message: Text("El libro se ha guardado exitosamente."), dismissButton: .default(Text("OK")))
                    }
                }
            }
            .navigationTitle("Agregar Libro")
        }
    }
    
    // Función para crear y guardar el libro
    private func guardarLibro() {
        let autor = Autor(nombre: nombreAutor, apellidos: apellidosAutor)
        let libro = Libro(
            titulo: titulo,
            anioPublicacion: Int(anioPublicacion) ?? 0,
            numeroPaginas: Int(numeroPaginas) ?? 0,
            precio: Double(precio) ?? 0.0,
            autor: autor,
            estadoLectura: estadoLectura,
            progresoLectura: estadoLectura == .completado ? 100 : progresoLectura
        )
        
        context.insert(libro)
        limpiarCampos()
        mostrandoAlerta = true
    }
    
    // Función para limpiar campos después de guardar
    private func limpiarCampos() {
        titulo = ""
        anioPublicacion = ""
        numeroPaginas = ""
        precio = ""
        nombreAutor = ""
        apellidosAutor = ""
        estadoLectura = .noIniciado
        progresoLectura = 0.0
    }
}

// Estilo de campo de texto personalizado con icono
struct VisualTextFieldStyle: TextFieldStyle {
    var iconName: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.blue)
            configuration
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

#Preview {
    AgregarLibroView()
}

