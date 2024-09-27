//
//  ContentView.swift
//  HolaMundo
//
//  Created by alumno on 27/9/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack{
            VStack{
                MapView()
                    .frame(height: 300)
                ImageCircle()
                    .offset(y:-100)
                    .padding(.bottom,-130)
            }
            
            VStack(alignment:.leading){
                Text("Facultad de ciencias")
                    .font(.title)
                    .offset(y:50)
                //Spacer()
                HStack{
                    Text("Universidad de Salamanca")
                        .offset(y:50)
                    Spacer()
                    HStack{
                        
                        Image(systemName:"location.fill" ).foregroundColor(.red)
                            .offset(y:50)
                        Text("Salamanca")
                            .offset(y:50)
                    }
                }
            }
        }
        //.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
