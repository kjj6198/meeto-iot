//
//  meetoApp.swift
//  meeto
//
//  Created by KALAN CHEN on 2022/05/08.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var bleManager: BluetoothManager?
    var backgroundTimer: BackgroundTimer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        backgroundTimer = BackgroundTimer()
        bleManager = BluetoothManager.shared
    }
}

@main
struct meetoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        
        WindowGroup {
#if os(macOS)
            ContentView().frame(minWidth: 800, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity, alignment: .center)
#else
            ContentView()
#endif
        }
    }
}
