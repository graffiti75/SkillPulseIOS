//
//  DateFormatter+Extensions.swift
//  SkillPulse
//
//  Utility extensions for date and time formatting
//

import Foundation

extension DateFormatter {
    /// Formatter for time display (HH:mm format)
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    /// Formatter for date display
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// Formatter for timestamp (ISO 8601)
    static let timestampFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
}

extension Date {
    /// Convert Date to time string (HH:mm)
    func toTimeString() -> String {
        DateFormatter.timeFormatter.string(from: self)
    }
    
    /// Convert Date to ISO 8601 timestamp string
    func toTimestampString() -> String {
        DateFormatter.timestampFormatter.string(from: self)
    }
    
    /// Create Date from time string (HH:mm)
    static func fromTimeString(_ timeString: String) -> Date? {
        DateFormatter.timeFormatter.date(from: timeString)
    }
    
    /// Create Date from ISO 8601 timestamp string
    static func fromTimestampString(_ timestamp: String) -> Date? {
        DateFormatter.timestampFormatter.date(from: timestamp)
    }
}

extension String {
    /// Validate if string is in valid time format (HH:mm)
    var isValidTimeFormat: Bool {
        let pattern = "^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, range: range) != nil
    }
    
    /// Convert time string to display format
    func formattedTime() -> String {
        guard isValidTimeFormat else { return self }
        return self
    }
}
