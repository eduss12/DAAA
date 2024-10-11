//
//  FavoriteButton.swift
//  Usal
//
//  Created by alumno on 11/10/24.
//

import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet:Bool  //Utilizamos binding para que se avariable mutable
    
    
    var body: some View {
        Button{
            isSet.toggle()//cambiar de true-->false /false -->true
        }label: {
            Label("Favorite",systemImage: isSet ? "star.fill" : "star")
                .labelStyle(.iconOnly)
                .foregroundColor(isSet ? .yellow : .gray)
        }
    }
}


