//
//  TimeInterval+Extension.swift
//  meeto
//
//  Created by KALAN CHEN on 2022/05/08.
//

import Foundation

extension TimeInterval {
    static func weeks(_ weeks: Double) -> TimeInterval {
        return weeks * TimeInterval.week
    }
    
    static var week: TimeInterval {
        return 7 * 24 * 60 * 60
    }
}
