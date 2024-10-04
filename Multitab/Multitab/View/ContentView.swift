//
//  ContentView.swift
//  Multitab
//
//  Created by alumno on 4/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            HomeView()
                .tabItem {
                Image(systemName: "house")
                    Text("home")
            }.tag(1)
            
            AboutView()
                .tabItem {
                Image(systemName: "menucard.fill")
                    Text("menu")
            }.tag(2)
            
            SettingsView()
                .tabItem {
                Image(systemName: "gear")
                    Text("gear")
            }.tag(3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
