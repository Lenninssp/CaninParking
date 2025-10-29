//
//  TestView.swift
//  ParkingApp
//
//  Created by Juan Camilo Montero Campo on 2025-10-15.
//

import SwiftUI

struct TestView: View {
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.clear)
              .glassEffect(.clear.tint(.gray.opacity(0.2)).interactive(), in: .rect(cornerRadius: 20.0))
              .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
              .frame(width: 350, height: 620)

    }
}

#Preview {
    TestView()
}
