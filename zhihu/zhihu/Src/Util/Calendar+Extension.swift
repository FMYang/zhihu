//
//  Calender.swift
//  zhihu
//
//  Created by yfm on 2023/10/12.
//

import Foundation

extension Calendar {
    
    /// 当前年
    static func currentYear() -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: Date())
        let year = components.year
        return year
    }
    
    /// 当前月
    static func currentMonth() -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: Date())
        let month = components.month
        return month
    }
    
    /// 当前日
    static func currentDay() -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date())
        let month = components.day
        return month
    }
    
    /// 通过年月，获取对于日期的所有日
    static func getDaysArray(year: Int, month: Int) -> [Int] {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        let startDate = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        let days = Array(range.lowerBound...range.upperBound-1)
        return days
    }
}
