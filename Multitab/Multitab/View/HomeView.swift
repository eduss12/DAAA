//
//  HomeView.swift
//  Multitab
//
//  Created by alumno on 4/10/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView(){
            VStack{
                Text("Example app tab view")
                    .font(.largeTitle)
                    .padding()
                NavigationLink(
                    destination: DetailView()){
                        Text("Abrir detailview")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            
                    }
                    .navigationTitle("DetailView")
            }
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
