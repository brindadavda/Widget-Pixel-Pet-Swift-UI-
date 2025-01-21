//
//  Date+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

extension TimeZone {
    
    static func currentUserTimeZoneGMTString() -> String {
        let currentUserTimeZone = TimeZone.current.identifier
        let timeZone = TimeZone(identifier: currentUserTimeZone)
        let timeZoneAbbreviation = timeZone?.abbreviation(for: Date()) ?? ""
        // Extract and keep only the letters from the abbreviation
        let gmtString = timeZoneAbbreviation.filter { $0.isLetter }
        return gmtString
    }
    
    static func currentUserUTCOffsetString() -> String {
        let currentUserTimeZone = TimeZone.current.identifier
        let timeZone = TimeZone(identifier: currentUserTimeZone)
        let utcOffset = timeZone?.secondsFromGMT() ?? 0
        let hours = utcOffset / 3600
        let offsetString = String(format: "%+d", hours)
        return offsetString
    }
    
}

typealias Formatter_TamagochiVVV = Formatter

extension Formatter_TamagochiVVV {
    
    static let dayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        return formatter
    }()
    
    static let dayNumberMonthName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
    
    static let dayNumberMonthNameShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
}

typealias Date_TamagochiVVV = Date

extension Date_TamagochiVVV {
    
    func formattedString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Set your desired format here
        return dateFormatter.string(from: self)
    }
    
    func getMonthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: self)
    }
    
    func isEqualTo(dayIndex: Int) -> Bool {
        dayIndex == Calendar.current.component(.day, from: self)
    }
    
    static func getVeryShortDayName(for dayIndex: Int) -> String {
        let calendar = Calendar.current
        let weekdays = calendar.shortWeekdaySymbols
        let adjustedIndex = (dayIndex + calendar.firstWeekday - 2) % 7
        return String(weekdays[adjustedIndex].prefix(1))
    }
    
    static func getWeeksInMonth(from selectedDate: Date) -> [[Int]] {
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let totalDaysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)!.count
        var weeks: [[Int]] = []
        var currentWeek = [Int](repeating: 0, count: 7)
        var dayIndex = 0
        var emptyDays = firstWeekday - calendar.firstWeekday
        if emptyDays < 0 {
            emptyDays += 7
        }
        for _ in 0..<emptyDays {
            currentWeek[dayIndex] = 0
            dayIndex += 1
        }
        for day in 1...totalDaysInMonth {
            currentWeek[dayIndex] = day
            dayIndex += 1
            if dayIndex == 7 {
                weeks.append(currentWeek)
                currentWeek = [Int](repeating: 0, count: 7)
                dayIndex = 0
            }
        }
        if dayIndex != 0 {
            weeks.append(currentWeek)
        }
        return weeks
    }
    
    func greetingBasedOnTime() -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<18:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    func formattedHourWithAMPM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a"
        return dateFormatter.string(from: self)
    }
    
    func daysLeftOrAgo(to targetDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: targetDate)
        if let days = components.day {
            if days > 0 {
                return "\(days) days left"
            } else if days < 0 {
                return "\(-days) days ago"
            } else {
                return "Today"
            }
        }
        return "Error calculating days"
    }
    
    func timeInWords() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        if var hour = components.hour, var minute = components.minute {
            var hourString = "\(hour)"
            var minuteString = "\(minute)"
            var period = "past"
            var needToUpdateMinutesString = true
            
            if [0, 15, 30, 45].contains(minute) {
                needToUpdateMinutesString = false
            }
            
            if minute == 0 {
                minuteString = "o'clock"
            } else if minute == 15 {
                minuteString = "quarter"
            } else if minute == 30 {
                minuteString = "half"
            } else if minute == 45 {
                minuteString = "quarter"
                hourString = "\(hour + 1)"
                hour += 1
                period = "to"
            } else if minute > 30 {
                minuteString = "\(60 - minute)"
                minute = 60 - minute
                hourString = "\(hour + 1)"
                hour += 1
                period = "to"
            }
            if let hourToString = hour.spelledOut() {
                hourString = hourToString
            }
            if needToUpdateMinutesString {
                if let minuteToString = minute.spelledOut() {
                    minuteString = minuteToString
                }
            }
            let timeString = "It is \(minuteString) \(period) \(hourString)"
            return timeString
        }
        return "Error converting time"
    }
    
    func angleForHourHand() -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        let hour = Double(components.hour ?? 0)
        let minute = Double(components.minute ?? 0)
        let totalMinutes = hour * 60.0 + minute
        return (totalMinutes / 720.0) * 360.0 // 12 hours in 360 degrees
    }
    
    func angleForMinuteHand() -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: self)
        let minute = Double(components.minute ?? 0)
        let second = Double(components.second ?? 0)
        let totalSeconds = minute * 60.0 + second
        return (totalSeconds / 3600.0) * 360.0 // 60 minutes in 360 degrees
    }
    
    func angleForSecondHand() -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second], from: self)
        let second = Double(components.second ?? 0)
        return (second / 60.0) * 360.0 // 60 seconds in 360 degrees
    }
    
    func ageString() -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: currentDate)
        
        var ageString = ""
        
        if let days = components.day, days > 0 {
            ageString += "\(days) day"
            if days != 1 {
                ageString += "s"
            }
        }
        
        if let hours = components.hour, hours > 0 {
            if !ageString.isEmpty {
                ageString += " "
            }
            ageString += "\(hours) hour"
            if hours != 1 {
                ageString += "s"
            }
        }
        
        if let minutes = components.minute, minutes > 0 {
            if !ageString.isEmpty {
                ageString += " "
            }
            ageString += "\(minutes) minute"
            if minutes != 1 {
                ageString += "s"
            }
        }
        
        return ageString.isEmpty ? "Just born" : ageString
    }
    
    func minutes(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: date, to: self)
        return components.minute ?? 0
    }
    
    func isSameMinutes(with date: Date) -> Bool {
        let calendar = Calendar.current
        let ourMinutes = calendar.component(.minute, from: self)
        let minutesToCompare = calendar.component(.minute, from: date)
        return ourMinutes == minutesToCompare
    }
    
}

extension Date_TamagochiVVV: RawRepresentable {
    
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
    
}
