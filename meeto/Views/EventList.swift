//
//  EventList.swift
//  meeto
//
//  Created by KALAN CHEN on 2022/05/08.
//

import SwiftUI

struct EventList: View {
    @EnvironmentObject var eventStore: EventStore
    
    var body: some View {
        VStack {
            List {
                if eventStore.events?.isEmpty ?? true {
                    Text("There is no event")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(eventStore.events!, id: \.self) { event in
                        VStack(alignment: .leading) {
                            Text(event.title).font(.headline)
                            Text("\(event.startDate) - \(event.endDate)").font(.caption)
                        }
                    }
                }
                
            }.listStyle(.inset)
            
        }
        
    }
}

struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        EventList()
    }
}
