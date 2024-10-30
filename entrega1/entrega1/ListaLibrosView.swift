//
//  ListaLibrosView.swift
//  entrega1
//
//  Created by alumno on 30/10/24.
//

import SwiftUI
import SwiftData

struct ListaLibrosView: View {
    @Query private var libros: [Libro]
    @State private var filtroEstado: EstadoLectura? = nil
    @Environment(\.modelContext) private var context // Asegúrate de tener acceso al contexto
    @State private var mostrarAlerta: Bool = false // Estado para mostrar la alerta de confirmación
    
    private var ritmoLectura: Double {
        UserDefaults.standard.double(forKey: "RitmoLectura")
    }
    
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

    var body: some View {
        NavigationView {
            VStack {
                Picker("Filtrar por Estado", selection: $filtroEstado) {
                    Text("Todos").tag(nil as EstadoLectura?)
                    ForEach(EstadoLectura.allCases, id: \.self) { estado in
                        Text(estado.rawValue).tag(estado as EstadoLectura?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding() // Añadir padding para un mejor espaciado

                List {
                    ForEach(librosFiltrados) { libro in
                        NavigationLink(destination: DetalleLibroView(libro: libro)) {
                            VStack(alignment: .leading) {
                                Text(libro.titulo)
                                    .font(.headline) // Título en negrita
                                Text("Autor: \(libro.autor.nombre) \(libro.autor.apellidos)")
                                Text("Estado: \(libro.estadoLectura.rawValue)")
                                    .foregroundColor(.gray) // Color gris para el estado
                            }
                        }
                        .swipeActions { // Agrega acciones de deslizamiento
                            Button(role: .destructive) {
                                eliminarLibro(libro)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }

                Text("Tiempo Total de Lectura: \(tiempoTotalLectura, specifier: "%.2f") minutos")
                    .padding() // Añadir padding para mejor espaciado
                    .font(.subheadline)
                    .foregroundColor(.blue) // Color azul para el texto

                // Botón para vaciar el almacén
                Button(action: {
                    mostrarAlerta = true
                }) {
                    Text("Vaciar Almacén")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
                .padding()
            }
            .navigationTitle("Lista de Libros")
            .alert(isPresented: $mostrarAlerta) { // Alertas para confirmar la acción
                Alert(title: Text("Confirmar Vaciar Almacén"),
                      message: Text("¿Estás seguro de que deseas vaciar el almacén de libros? Esta acción no se puede deshacer."),
                      primaryButton: .destructive(Text("Eliminar")) {
                          vaciarAlmacen() // Vaciar el almacén
                      },
                      secondaryButton: .cancel())
            }
        }
    }

    // Método para eliminar un libro
    private func eliminarLibro(_ libro: Libro) {
        context.delete(libro) // Elimina el libro del contexto
    }
    
    // Método para vaciar el almacén
    private func vaciarAlmacen() {
        for libro in libros {
            context.delete(libro) // Elimina cada libro del contexto
        }
    }
}

#Preview {
    ListaLibrosView()
}

