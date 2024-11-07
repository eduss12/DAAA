import SwiftUI
import SwiftData

struct ListaLibrosView: View {
    @Query private var libros: [Libro]
    @State private var filtroEstado: EstadoLectura? = nil
    @Environment(\.modelContext) private var context
    @State private var mostrarAlerta: Bool = false
    
    @AppStorage("ritmoLectura") var ritmoLectura: Double = 1.0
    
    /*private var ritmoLectura: Double {
        UserDefaults.standard.double(forKey: "RitmoLectura")
    }*/
    
    private var librosFiltrados: [Libro] {
        if let filtro = filtroEstado {
            return libros.filter { $0.estadoLectura == filtro }
        }
        return libros
    }
    
    private var tiempoTotalLectura: Double {
        libros.reduce(0) { total, libro in
            total + (Double(libro.numeroPaginas) * (libro.progresoLectura / 100) / ritmoLectura)
        }
    }

    private var precioTotal: Double {
        libros.reduce(0) { total, libro in
            total + libro.precio
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Mostrar número total de libros
                Text("Total de libros: \(libros.count)")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.top)

                // Filtro por estado de lectura
                Picker("Filtrar por Estado", selection: $filtroEstado) {
                    Text("Todos").tag(nil as EstadoLectura?)
                    ForEach(EstadoLectura.allCases, id: \.self) { estado in
                        Text(estado.rawValue).tag(estado as EstadoLectura?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.top)

                // Lista de libros
                List {
                    ForEach(librosFiltrados) { libro in
                        NavigationLink(destination: DetalleLibroView(libro: libro)) {
                            HStack {
                                Image(systemName: "book.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(libro.titulo)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Autor: \(libro.autor.nombre) \(libro.autor.apellidos)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Estado: \(libro.estadoLectura.rawValue)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                eliminarLibro(libro)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
                
                // Tiempo total de lectura
                Text("Tiempo Total de Lectura: \(tiempoTotalLectura, specifier: "%.2f") minutos")
                    .padding()
                    .font(.subheadline)
                    .foregroundColor(.blue)

                // Precio total de todos los libros
                Text("Precio Total de Libros: \(precioTotal, specifier: "%.2f") €")
                    .padding()
                    .font(.subheadline)
                    .foregroundColor(.green)

                // Botón para vaciar el almacén
                Button(action: {
                    mostrarAlerta = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Vaciar Almacén")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                .padding(.bottom)
            }
            .navigationTitle("Lista de Libros")
            .alert(isPresented: $mostrarAlerta) {
                Alert(
                    title: Text("Confirmar Vaciar Almacén"),
                    message: Text("¿Estás seguro de que deseas vaciar el almacén de libros? Esta acción no se puede deshacer."),
                    primaryButton: .destructive(Text("Eliminar")) {
                        vaciarAlmacen()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    // Método para eliminar un libro
    private func eliminarLibro(_ libro: Libro) {
        context.delete(libro)
    }
    
    // Método para vaciar el almacén
    private func vaciarAlmacen() {
        for libro in libros {
            context.delete(libro)
        }
    }
}

#Preview {
    ListaLibrosView()
}

