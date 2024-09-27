//
//  ContentView.swift
//  practica2
//
//  Created by alumno on 27/9/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
        //ExtractedView()
            User()
            Text("Aqui tengo un texto debajo")
            Divider().background(.blue)
            Spacer()
        
            HStack{
                Text("HStack item1")
                Text("HStack item2")
                Text("HStack item2")

            }
            Spacer()
            Divider().background(.black)
            HStack{
                Text("HStack item1")
                Text("HStack item2")
                Text("HStack item2")

            }
            ZStack{
                Text("ZStack item1")
                    .padding()
                    .background()
                Text("ZStack item2")
                    .background(.green)

            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ExtractedView: View{
    var body: some View{
        Image(systemName: "globe")
            .imageScale(.large)
            .foregroundColor(.accentColor)
        Text("Hello, world!")
        Text("Aqui tengo un texto abajo")
            .foregroundColor(Color.red)
            .colorInvert()
    }}

struct User: View{
    var body: some View{
        HStack{
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                Spacer()
            Text("Hello, world!")
        }
    }}
