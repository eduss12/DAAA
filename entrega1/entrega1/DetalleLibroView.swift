import SwiftUI
import SwiftData

struct DetalleLibroView: View {
    @Environment(\.modelContext) private var context // Acceso al contexto para editar
    @State private var mostrandoEditor = false // Estado para mostrar el editor
    @State private var tituloEditado: String
    @State private var anioPublicacionEditado: String
    @State private var numeroPaginasEditado: String
    @State private var precioEditado: String
    @State private var estadoLecturaEditado: EstadoLectura
    @State private var progresoLecturaEditado: Double

    var libro: Libro

    init(libro: Libro) {
        self.libro = libro
        _tituloEditado = State(initialValue: libro.titulo)
        _anioPublicacionEditado = State(initialValue: "\(libro.anioPublicacion)")
        _numeroPaginasEditado = State(initialValue: "\(libro.numeroPaginas)")
        _precioEditado = State(initialValue: "\(libro.precio)")
        _estadoLecturaEditado = State(initialValue: libro.estadoLectura)
        _progresoLecturaEditado = State(initialValue: libro.progresoLectura)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Título del libro
            HStack {
                Image(systemName: "book.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                Text(libro.titulo)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.bottom)

            // Información del autor
            Text("Autor: \(libro.autor.nombre) \(libro.autor.apellidos)")
                .font(.title2)
                .foregroundColor(.secondary)

            Divider()

            // Detalles del libro
            VStack(alignment: .leading, spacing: 8) {
                Label("Año de Publicación: \(libro.anioPublicacion)", systemImage: "calendar")
                Label("Número de Páginas: \(libro.numeroPaginas)", systemImage: "book")
                Label("Precio: \(libro.precio, specifier: "%.2f") €", systemImage: "eurosign.circle")
                Label("Estado de Lectura: \(libro.estadoLectura.rawValue)", systemImage: "bookmark.circle")
                Label("Progreso: \(libro.progresoLectura, specifier: "%.1f")%", systemImage: "gauge")
            }
            .font(.body)
            .foregroundColor(.gray)

            Spacer()

            // Botón de editar
            Button(action: {
                mostrandoEditor = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Editar Información")
                        .fontWeight(.bold)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Detalles del Libro")
        .sheet(isPresented: $mostrandoEditor) {
            EditorLibroView(
                titulo: $tituloEditado,
                anioPublicacion: $anioPublicacionEditado,
                numeroPaginas: $numeroPaginasEditado,
                precio: $precioEditado,
                estadoLectura: $estadoLecturaEditado,
                progresoLectura: $progresoLecturaEditado
            ) {
                actualizarLibro()
                mostrandoEditor = false
            }
        }
    }

    // Método para guardar los cambios en el libro
    private func actualizarLibro() {
        libro.titulo = tituloEditado
        libro.anioPublicacion = Int(anioPublicacionEditado) ?? libro.anioPublicacion
        libro.numeroPaginas = Int(numeroPaginasEditado) ?? libro.numeroPaginas
        libro.precio = Double(precioEditado) ?? libro.precio
        libro.estadoLectura = estadoLecturaEditado
        libro.progresoLectura = progresoLecturaEditado

        do {
            try context.save()
        } catch {
            print("Error al guardar los cambios: \(error.localizedDescription)")
        }
    }
}

// Vista para editar información del libro
struct EditorLibroView: View {
    @Binding var titulo: String
    @Binding var anioPublicacion: String
    @Binding var numeroPaginas: String
    @Binding var precio: String
    @Binding var estadoLectura: EstadoLectura
    @Binding var progresoLectura: Double

    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Libro")) {
                    TextField("Título", text: $titulo)
                    TextField("Año de Publicación", text: $anioPublicacion)
                        .keyboardType(.numberPad)
                    TextField("Número de Páginas", text: $numeroPaginas)
                        .keyboardType(.numberPad)
                    TextField("Precio", text: $precio)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Estado de Lectura")) {
                    Picker("Estado de Lectura", selection: $estadoLectura) {
                        ForEach(EstadoLectura.allCases, id: \.self) { estado in
                            Text(estado.rawValue).tag(estado)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // Cambiar el progreso automáticamente al cambiar el estado
                    .onChange(of: estadoLectura) { newEstado in
                        if newEstado == .completado {
                            progresoLectura = 100.0
                        } else if newEstado == .noIniciado {
                            progresoLectura = 0.0
                        }
                    }

                    if estadoLectura == .enProgreso {
                        Slider(value: $progresoLectura, in: 0...100, step: 1)
                        Text("Progreso: \(Int(progresoLectura))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Editar Libro")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        onSave()
                    }
                }
            }
        }
    }
}

#Preview {
    DetalleLibroView(libro: Libro(
        titulo: "Ejemplo",
        anioPublicacion: 2022,
        numeroPaginas: 300,
        precio: 19.99,
        autor: Autor(nombre: "Autor", apellidos: "Ejemplo"),
        estadoLectura: .noIniciado,
        progresoLectura: 0.0
    ))
}

