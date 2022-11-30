import Foundation
import EventKit
import SwiftUI
import Combine

typealias Action = () -> ()

class EventStore: ObservableObject {
    static let shared = EventStore()
    
    private var subscribers: Set<AnyCancellable> = []

    private let identifier = "14AA4522-C4C5-4315-99F0-6DA2D6853273" // real
//    private let identifier = "D17C1FE1-3F66-42DA-BC1F-73540F27A875" // testing
    
    let eventStore = EKEventStore()
    
    @Published var selectedCalendars: Set<EKCalendar>?
    
    @Published var events: [EKEvent]?
    
    private init() {
        selectedCalendars = loadSelectedCalendars()
        
        if selectedCalendars == nil {
            if EKEventStore.authorizationStatus(for: .event) == .authorized {
                selectedCalendars = Set([eventStore.defaultCalendarForNewEvents].compactMap({ $0 }))
            }
        }
        
        $selectedCalendars.sink { [weak self] (calendars) in
            self?.saveSelectedCalendars(calendars)
            self?.loadAndUpdateEvents()
        }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .sink { [weak self] (notification) in
                self?.loadAndUpdateEvents()
            }
            .store(in: &subscribers)
    }
    
    private func loadSelectedCalendars() -> Set<EKCalendar>? {
        let calendars = eventStore.calendars(for: .event).filter({ $0.calendarIdentifier == identifier })
        guard !calendars.isEmpty else { return nil }
        return Set(calendars)
    }
    
    private func saveSelectedCalendars(_ calendars: Set<EKCalendar>?) {
        if let identifiers = calendars?.compactMap({ $0.calendarIdentifier }) {
            UserDefaults.standard.set(identifiers, forKey: "CalendarIdentifiers")
        }
    }
    
    func loadAndUpdateEvents() {
        loadEvents(completion: { (events) in
            DispatchQueue.main.async {
                self.events = events
            }
        })
    }
    
    func requestAccess(onGranted: @escaping Action, onDenied: @escaping Action) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                onGranted()
            } else {
                onDenied()
            }
        }
    }
    
    func loadEvents(completion: @escaping (([EKEvent]?) -> Void)) {
        requestAccess(onGranted: { [self] in
            let weekFromNow = Date().advanced(by: TimeInterval.week)
            
            let predicate = self.eventStore.predicateForEvents(withStart: Date(), end: weekFromNow, calendars: Array(self.selectedCalendars ?? []))
            
            let events = self.eventStore.events(matching: predicate).filter({ $0.calendar.calendarIdentifier == self.identifier })
            completion(events)
        }) {
            completion(nil)
        }
    }
    
    deinit {
        subscribers.forEach { (sub) in
            sub.cancel()
        }
    }
}
