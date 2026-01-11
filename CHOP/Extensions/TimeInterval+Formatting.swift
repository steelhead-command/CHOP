import Foundation

extension TimeInterval {
    /// Formats as "2:34:17" or "34:17" or "0:17"
    var formatted: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    /// Formats as "2h 34m" or "34m" or "< 1m"
    var shortFormatted: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }

    /// Formats as countdown string "Ready in 2h 34m"
    var countdownString: String {
        if self <= 0 {
            return "Ready!"
        }
        return "Ready in \(shortFormatted)"
    }
}
