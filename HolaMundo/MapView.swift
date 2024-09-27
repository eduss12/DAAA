//
//  MapView.swift
//  HolaMundo
//
//  Created by alumno on 27/9/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    var body: some View {
        Map(coordinateRegion: $region)
    }
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 40.96704364517705,
            longitude: -5.674402865784114)
        ,span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
