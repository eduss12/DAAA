//
//  ContentView.swift
//  Usal
//
//  Created by alumno on 11/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView{
            
            HomeView()
                .tabItem{
                    Label("home",systemImage: "house")
                }
            InfoView()
                .tabItem{
                    Label("info",systemImage:"info")
                }
            FacultadList().environmentObject(ModelData())
                .tabItem{
                    Label("facultad",systemImage: "graduationcap")
                }
            
        }
        

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
