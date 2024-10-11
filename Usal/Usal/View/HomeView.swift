//
//  HomeView.swift
//  Usal
//
//  Created by alumno on 11/10/24.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        Text("This is the Detail View")
            .font(.title)
            .navigationTitle("Detail")
    }
}

struct HomeView: View {
    var body: some View {
         NavigationView {
             VStack {
                 Text("Welcome to the Home Tab")
                     .font(.largeTitle)
                     .padding()
                 
                 NavigationLink(destination: DetailView()) {
                     Text("Go to Detail")
                         .foregroundColor(.blue)
                         .padding()
                         .background(Color.gray.opacity(0.2))
                         .cornerRadius(10)
                 }
             }
             .navigationTitle("Home")
         }
     }
    
}
