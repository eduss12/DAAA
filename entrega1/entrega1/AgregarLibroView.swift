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

    var body: some View {
        NavigationView {
            Form {
                // Información básica del libro
                TextField("Título", text: $titulo)
                TextField("Año de Publicación", text: $anioPublicacion)
                    .keyboardType(.numberPad)
                TextField("Número de Páginas", text: $numeroPaginas)
                    .keyboardType(.numberPad)
                TextField("Precio", text: $precio)
                    .keyboardType(.decimalPad)
                
                // Información del autor
                TextField("Nombre del Autor", text: $nombreAutor)
                TextField("Apellidos del Autor", text: $apellidosAutor)
                
                // Estado de lectura - Botones en lugar de Picker
                Text("Estado de Lectura")
                HStack {
                    Button("No Iniciado") {
                        estadoLectura = .noIniciado
                        progresoLectura = 0.0
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(estadoLectura == .noIniciado ? .blue : .primary)
                    
                    Button("En Progreso") {
                        estadoLectura = .enProgreso
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(estadoLectura == .enProgreso ? .blue : .primary)
                    
                    Button("Completado") {
                        estadoLectura = .completado
                        progresoLectura = 100.0
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(estadoLectura == .completado ? .blue : .primary)
                }
                
                // Slider de progreso (solo si está en progreso)
                if estadoLectura == .enProgreso {
                    Slider(value: $progresoLectura, in: 0...100, step: 1)
                    Text("Progreso: \(Int(progresoLectura))%")
                }
                
                // Botón para guardar el libro
                Button("Guardar Libro") {
                    guardarLibro()
                }
            }
            .navigationTitle("Agregar Libro")
        }
    }
    
    // Función para crear y guardar el libro
    private func guardarLibro() {
        // Creación del autor
        let autor = Autor(nombre: nombreAutor, apellidos: apellidosAutor)
        
        // Creación del libro con los datos ingresados
        let libro = Libro(
            titulo: titulo,
            anioPublicacion: Int(anioPublicacion) ?? 0,
            numeroPaginas: Int(numeroPaginas) ?? 0,
            precio: Double(precio) ?? 0.0,
            autor: autor,
            estadoLectura: estadoLectura,
            progresoLectura: estadoLectura == .completado ? 100 : progresoLectura
        )
        
        // Inserción del libro en el contexto de datos
        context.insert(libro)
        
        // Limpieza de campos después de guardar
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

#Preview {
    AgregarLibroView()
}

