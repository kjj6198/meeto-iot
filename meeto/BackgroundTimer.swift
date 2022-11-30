//
//  BackgroundTimer.swift
//  meeto
//
//  Created by KALAN CHEN on 2022/05/08.
//

import Foundation
import Combine
import EventKit

class BackgroundTimer {
    var eventStore: EventStore = EventStore.shared
    var timer: Timer? = nil
    var countdown: Timer? = nil
    var countdown2: Timer? = nil
    var subscriber: AnyCancellable? = nil

    
    init() {
        subscriber = eventStore.$events.sink { [self] events in
            if (self.timer != nil) {
                self.timer?.invalidate()
                self.timer = nil
            }
            self.countdown2?.invalidate()
            self.countdown?.invalidate()
            self.countdown = nil

            if !(events?.isEmpty ?? true) {
                guard let event = events?[0] else {
                    print("There is no upcoming event")
                    return
                }

                scheduleStartEvent(event)
            }
        }
    }
    
    
    func scheduleStartEvent(_ event: EKEvent) {
        let interval = event.startDate.timeIntervalSinceNow
        self.timer = Timer.scheduledTimer(
                timeInterval: interval,
                target: self,
                selector: #selector(self.sendStartSignal(timer:)),
                userInfo: event,
                repeats: false
        )

        self.countdown = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            formatter.allowedUnits = [.hour, .minute]
            let timeFormat = formatter.string(from: event.startDate.timeIntervalSinceNow) ?? "N/A"
            var str = "次のミーティング！\(event.title ?? "N/A") in \(timeFormat)"
            if event.startDate.timeIntervalSinceNow < 60 * 3 {
                str = "ミーティングまもなく開始します！\(event.title ?? "N/A") in \(timeFormat)"
            }
            BluetoothManager.shared.write(str: str)
        }
    }
    
    func scheduleEndEvent(_ event: EKEvent) {
        self.timer?.invalidate()
        self.timer = nil
        
        let interval = event.endDate.timeIntervalSinceNow
        print("interval:", interval)
        self.timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(self.sendEndSignal(timer:)),
            userInfo: event,
            repeats: false
        )
        
        countdown2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            formatter.allowedUnits = [.hour, .minute]
            let timeFormat = formatter.string(from: event.endDate.timeIntervalSinceNow) ?? "N/A"
            let str = "今いそがしいです！\(event.title ?? "N/A") \(timeFormat) left"
            BluetoothManager.shared.write(str: str)
        }
    }
    
    @objc func sendEndSignal(timer: Timer) {
        let info = timer.userInfo as! EKEvent
        self.countdown?.invalidate()
        self.timer?.invalidate()
        print(info.title)
        print("event ended, you're free!")
        eventStore.loadAndUpdateEvents()
    }
    
    

    @objc func sendStartSignal(timer: Timer) {
        let info = timer.userInfo as! EKEvent
        self.scheduleEndEvent(info)
        self.countdown?.invalidate()
    }
}
