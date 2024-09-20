//
//  ContentView.swift
//  Practica1_1
//
//  Created by alumno on 20/9/24.
//
import SwiftUI

struct ContentView: View {
    @State private var mensaje = "suscribir"
    @State private var colorDeFondo = Color.white
    
    var body: some View {
        NavigationView {
            ZStack {
                colorDeFondo
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(mensaje)
                        .padding()
                        .font(.largeTitle)
                    
                    Image("madrid")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.orange)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.red, lineWidth: 4)
                        )
                        .padding()

                    Button(action: {
                        mensaje = "¡Campeones!"
                        colorDeFondo = Color.blue
                    }) {
                        Text("Campeones")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    NavigationLink(destination: InicioView()) {
                        Text("Volver a Inicio")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
}

struct InicioView: View {
    var body: some View {
        ZStack {
            Color.red
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Pantalla de Inicio")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)

                Image("barca") // Asegúrate de que la imagen se llame "barca" en tus Assets
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding()
                
                // Botón para llamar a Laporta
                Button(action: {
                    // URL de la página del FC Barcelona
                    if let url = URL(string: "https://www.fcbarcelona.com/en") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Llamar a Laporta")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


