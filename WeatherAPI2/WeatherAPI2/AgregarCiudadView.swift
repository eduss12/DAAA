//
//  AgregarCiudadView.swift
//  WeatherAPI2
//
//  Created by alumno on 22/11/24.
//

import SwiftUI
import CoreLocation //Para usar geocode

struct AgregarCiudadView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss)  var dismiss
    @State private var nombre: String = ""
    @State private var resultados: [CLPlacemark] = []
    @State private var msgerror: String? = nil
    
    private let geocoder = CLGeocoder()
    
    var body: some View {
        NavigationStack{
            Form{
                Section(header: Text("Detalles de la ciudad")){
                    TextField("Nombre de la ciudad",text: $nombre)
                        .padding()
                        .onChange(of: nombre){
                            buscarCoordenadasCiudad()
                        }
                }
            }
            
            if !resultados.isEmpty{
                Section(header: Text("Seleccione ciudad")){
                    List(resultados.indices, id: \.self){ index in
                        let place = resultados[index]
                        Button(action: {
                            guardarCiudad(placemark: place)
                        }) {
                            
                            if let localidad = place.locality {
                                Text(localidad)
                                    .font(.subheadline)
                            }
                            if let pais = place.country{
                                Text(pais)
                            }
                            if let adminArea = place.administrativeArea{
                                Text(adminArea)
                            }
                            if let subLocality = place.subLocality{
                                Text(subLocality)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func guardarCiudad (placemark: CLPlacemark){
        guard let location = placemark.location else{
            return
        }
        
        let nombreCiudad = placemark.locality ?? nombre
        let latitud = location.coordinate.latitude
        let longitud = location.coordinate.longitude
        
        let nuevaCiudad = Ciudad(nombre: nombreCiudad, latitud: latitud, longitud: longitud)
        
        modelContext.insert(nuevaCiudad) //insertar en swiftData la nueva ciudad
        
        do {
            try modelContext.save()
            dismiss()
            
        } catch {
            print("Error al guardar la ciudad")
        }
        
        
    }
    private func buscarCoordenadasCiudad(){
        self.resultados = []
        
        //metodo para buscar lat,longitud de una ciudad pasada un nombre
        geocoder.geocodeAddressString(nombre){ (places,error) in
            if let error = error {
                print(error.localizedDescription)
                msgerror = "Error en la busqueda"
                return
            }
            
            guard let places = places, !places.isEmpty else{
                msgerror = "No se encontraron resultados en la busqueda"
                return
            }
            print(places)
            self.resultados = places
            
        }
    }
}

#Preview {
    AgregarCiudadView()
}
