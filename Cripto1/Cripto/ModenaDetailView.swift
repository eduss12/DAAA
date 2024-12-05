//
//  ModelaDetailView.swift
//  Cripto
//
//  Created by Alberto on 2/12/24.
//

import SwiftUI

struct CryptoDetailView: View {
    let crypto: Moneda
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: crypto.symbol)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            
            Text(crypto.name)
                .font(.largeTitle)
            
            Text("Symbol: \(crypto.symbol.uppercased())")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Price: $\(crypto.priceUSD, specifier: "%.2f")")
                .font(.title)
                .foregroundColor(.blue)
            
            Text("24h Change: \(crypto.priceUSD, specifier: "%.2f")%")
                .font(.headline)
                .foregroundColor(crypto.priceUSD > 0 ? .green : .red)
            
            Spacer()
        }
        .padding()
    }
}
