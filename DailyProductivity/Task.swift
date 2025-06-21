import Foundation

struct Habit: Identifiable, Codable, Equatable {
    let id = UUID()
    var name: String
    var priority: Priority
    var dueDate: Date?
    var isCompleted: Bool
    var isRecurring: Bool
    var streak: Int = 0
    var lastCompletedDate: Date?
    
    enum Priority: String, Codable, CaseIterable {
        case low
        case medium
        case high
    }
    
    // Check if habit is completed today
    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompletedDate else { return false }
        return Calendar.current.isDate(lastCompleted, inSameDayAs: Date())
    }
    
    // Mark habit as completed for today
    mutating func markCompleted() {
        isCompleted = true
        lastCompletedDate = Date()
        streak += 1
    }
    
    // Reset habit for a new day
    mutating func resetForNewDay() {
        if let lastCompleted = lastCompletedDate {
            let calendar = Calendar.current
            if !calendar.isDate(lastCompleted, inSameDayAs: Date()) {
                isCompleted = false
            }
        }
    }
    
    static func saveHabits(_ habits: [Habit]) {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "SavedHabits")
        }
    }
    
    static func loadHabits() -> [Habit] {
        if let data = UserDefaults.standard.data(forKey: "SavedHabits"),
           let habits = try? JSONDecoder().decode([Habit].self, from: data) {
            return habits
        }
        return []
    }
    
    // Reset all habits for a new day
    static func resetHabitsForNewDay(_ habits: inout [Habit]) {
        for i in habits.indices {
            habits[i].resetForNewDay()
        }
    }
} 
