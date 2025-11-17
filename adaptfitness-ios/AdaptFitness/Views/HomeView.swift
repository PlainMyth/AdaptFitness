//
//  HomeView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/15/25.
//

import SwiftUI

// Day struct for calendar display
struct Day: Identifiable {
    let id = UUID()
    let date: Date
    let isCompleted: Bool
}

// Helper function to generate current week days
func generateCurrentWeek(completedWorkouts: [Date]) -> [Day] {
    let calendar = Calendar.current
    let today = Date()
    
    // Get start of week (Monday)
    let weekday = calendar.component(.weekday, from: today)
    let daysFromMonday = (weekday + 5) % 7 // Convert Sunday=1 to Monday=0
    guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
        return []
    }
    
    var days: [Day] = []
    for i in 0..<7 {
        if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
            let isCompleted = completedWorkouts.contains { calendar.isDate($0, inSameDayAs: date) }
            days.append(Day(date: date, isCompleted: isCompleted))
        }
    }
    return days
}

// Placeholder HorizontalCalendar view
struct HorizontalCalendar: View {
    let days: [Day]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(days) { day in
                VStack(spacing: 4) {
                    Text(dayOfWeekString(from: day.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(Calendar.current.component(.day, from: day.date))")
                        .font(.headline)
                        .foregroundColor(day.isCompleted ? .green : .primary)
                    if day.isCompleted {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(width: 40)
                .padding(.vertical, 8)
                .background(Calendar.current.isDateInToday(day.date) ? Color.blue.opacity(0.1) : Color.clear)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    private func dayOfWeekString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct HomePageView: View {
    @Binding var isLoggedIn: Bool
    @State private var selectedTab: FooterTabBar.Tab = .home
    let calendar = Calendar.current
    @State private var days: [Day] = []
    @State private var showingAddGoalForm = false
    @State private var showingAddWorkoutForm = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showBarcodeScanner = false
    @State private var scannedBarcode: String?
    @State private var showingSettings = false
    
//    hardcoded data used to mimic returned request ============
    
    let user: User
    @State private var goals: [Goal] = Goal.exampleGoals
    @State private var fitnessRecords: [FitnessRecord] = FitnessRecord.exampleRecords                                                                           
    @State private var foods: [FoodEntry] = FoodEntry.exampleFoodEntries
    
//  ============================================================
    
    var body: some View {
        VStack(spacing: 0) {
            // Show different views based on selected tab
            if selectedTab == .browse {
                BrowseWorkoutsView()
            } else if selectedTab == .stats {
                TrackingView()
            } else if selectedTab == .calendar {
                GoalCalendarView()
            } else {
                // Home view content
                homeContent
            }
            
            // Footer Tabs (always visible)
            FooterTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .overlay(
            // Settings button in top-left corner
            VStack {
                HStack {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
        )
        .sheet(isPresented: $showingSettings) {
            ProfileView()
        }
    }
    
    var homeContent: some View {
        VStack {
            // Header with streak
            HStack {
                Spacer()
                
                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill") // fire icon
                        .foregroundColor(.orange)
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("\(user.loginStreak ?? 0)") // streak number from user parameter
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 2)
            }
            
            Spacer().frame(height: 20)
            
            // Hor Calendar
            HStack(spacing: 10) {
                // where calendarview thing would go
                HorizontalCalendar(days: days)
                    .onAppear {
                        let calendar = Calendar.current
                        
                        //the value in this array should be the current day.
                        //So we should check all the previous days until we go back to Monday                                                                   
                        let mockCompletedDates: [Date] = [
                            calendar.date(byAdding: .day, value: -2, to: Date())!,                                                                              
                            calendar.date(byAdding: .day, value: 1, to: Date())!,                                                                               
                            Date()
                        ]
                        days = generateCurrentWeek(completedWorkouts:mockCompletedDates)                                                                        
                    }
            }
            
//          GOAL BAR =================================
            Text("Goals")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 40) {
                    ForEach(goals) { goal in
                        GoalTileView(goal: goal, color: .blue)
                    }
//                  GOAL FORM =================================
                    Button(action: {
                            showingAddGoalForm = true
                    }) {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)                                                                         
                                        .frame(width: 80, height: 80)

                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                                Text("Add Goal")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 120)
                        }
                        .buttonStyle(PlainButtonStyle()) // removes default button styling                                                                      
                        .sheet(isPresented: $showingAddGoalForm) {
                            AddGoalForm(goals: $goals)
                        }
                    }
                }
                .padding(.horizontal)
                .contentMargins(.horizontal, 20)
            
//           spacing color
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            
//            intended color
//            .background(Color(.systemBackground).ignoresSafeArea())
            .onAppear {
                // Example: Simulate progress updates after data fetch
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        // TODO: Animations not working
//                        goals[0].progress = goals[0].progress / goals[0].goalAmount                                                                           
//                        goals[1].progress = goals[1].progress / goals[1].goalAmount                                                                           
                    }
                }
            }
            
    
            
            // Entries
            // TODO: Test entries
            ScrollView {
                VStack(spacing: 20) {
                    MealsView(meals: Meal.exampleMeals)
                }
                .padding(.top, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Originally meant for other things, but now idk
            ZStack {

                // Floating button
                VStack {
                    HStack {
                        Spacer() // push it to bottom-right

//                        Camera Button
                        // TODO: Camera not working in simulation, check real phone, then Info.plist                                                            
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                        if let barcode = scannedBarcode {
                            VStack {
                                Text("Scanned Barcode:")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Text(barcode)
                                    .font(.system(.body, design: .monospaced))
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding()
                            }
                        }

                        Button(action: {
                            showBarcodeScanner = true
                        }) {
                            Image(systemName: "barcode")
                                .font(.system(size: 24, weight: .bold))
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)                                                                      
                        }
                        .sheet(isPresented: $showBarcodeScanner) {
                            BarcodeScannerView(scannedCode: $scannedBarcode)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomePageView(isLoggedIn: .constant(true), user: .exampleUser)
}
