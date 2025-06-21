//
//  ContentView.swift
//  Zug Focus and Do
//
//  Created by Rodrigo Carballo on 6/12/25.
//

import SwiftUI


struct ContentView: View {
    @State private var habits: [Habit] = []
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(habits.indices, id: \.self) { index in
                    HStack {
                        Button(action: {
                            toggleHabitCompletion(at: index)
                        }) {
                            Image(systemName: habits[index].isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habits[index].isCompletedToday ? .green : .gray)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(habits[index].name)
                                    .font(.headline)
                                    .strikethrough(habits[index].isCompletedToday)
                                    .foregroundColor(habits[index].isCompletedToday ? .gray : .primary)
                                Spacer()
                                Text("🔥 \(habits[index].streak)")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: priorityIcon(for: habits[index].priority))
                                        .foregroundColor(priorityColor(for: habits[index].priority))
                                        .font(.caption)
                                    Text(habits[index].priority.rawValue.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                if habits[index].isRecurring {
                                    Image(systemName: "repeat")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteHabits)
            }
            .navigationTitle("Habits")
            .toolbar {
                Button(action: {
                    showingAddHabit = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(habits: $habits)
            }
            .onAppear {
                loadAndResetHabits()
            }
            .onChange(of: habits) { oldValue, newValue in
                Habit.saveHabits(newValue)
            }
        }
    }
    
    private func priorityIcon(for priority: Habit.Priority) -> String {
        switch priority {
        case .high:
            return "flame.fill"
        case .medium:
            return "exclamationmark.circle.fill"
        case .low:
            return "minus.circle.fill"
        }
    }
    
    private func priorityColor(for priority: Habit.Priority) -> Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .gray
        }
    }
    
    private func toggleHabitCompletion(at index: Int) {
        if habits[index].isCompletedToday {
            // Uncheck the habit
            habits[index].isCompleted = false
            habits[index].lastCompletedDate = nil
            if habits[index].streak > 0 {
                habits[index].streak -= 1
            }
        } else {
            // Mark as completed
            habits[index].markCompleted()
        }
    }
    
    private func loadAndResetHabits() {
        habits = Habit.loadHabits()
        Habit.resetHabitsForNewDay(&habits)
    }
    
    private func deleteHabits(offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }
}

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var habits: [Habit]
    
    @State private var habitName = ""
    @State private var priority = Habit.Priority.medium
    @State private var isRecurring = true
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Habit Name", text: $habitName)
                
                Picker("Priority", selection: $priority) {
                    ForEach(Habit.Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue.capitalized)
                    }
                }
                
                Toggle("Daily Habit", isOn: $isRecurring)
            }
            .navigationTitle("New Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let newHabit = Habit(
                        name: habitName,
                        priority: priority,
                        dueDate: nil,
                        isCompleted: false,
                        isRecurring: isRecurring,
                        streak: 0
                    )
                    habits.append(newHabit)
                    dismiss()
                }
                .disabled(habitName.isEmpty)
            )
        }
    }
}

#Preview {
    ContentView()
}
