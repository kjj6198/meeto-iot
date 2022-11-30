//
//  SwiftUIView.swift
//  meeto
//
//  Created by KALAN CHEN on 2022/05/08.
//

import SwiftUI

struct RefreshButton: View {
    

    var body: some View {
        Button("Refresh") {
            
        }
        .font(.headline)
        .padding([.leading, .trailing], 12.0)
        .cornerRadius(5.0)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshButton()
    }
}
