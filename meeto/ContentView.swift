//
//  ContentView.swift
//  meeto
//
//  Created by KALAN CHEN on 2022/05/08.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var eventStore = EventStore.shared
    @State private var text = ""
    
    var body: some View {
        VStack {
            TextField("Please enter...", text: $text)
            Button(action: {
                BluetoothManager.shared.write(str: text)
            }) {
                Text("Write")
            }
            Button(action: {
                BluetoothManager.shared.scan()
            }) {
                Text("Scan")
            }
            RefreshButton()
            Text("Hello, world!")
                .padding()
            EventList()
        }.environmentObject(eventStore)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
