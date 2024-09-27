//
//  ImageCircle.swift
//  HolaMundo
//
//  Created by alumno on 27/9/24.
//

import SwiftUI

struct ImageCircle: View {
    var body: some View {
        Image( "facultad")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .overlay{
                Circle().stroke(.blue,lineWidth: 3)
            }
            
        
        
    }
}

struct ImageCircle_Previews: PreviewProvider {
    static var previews: some View {
        ImageCircle()
    }
}
