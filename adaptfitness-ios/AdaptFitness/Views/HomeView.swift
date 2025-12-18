//
//  HomeView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/15/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.isAutoLoggingIn {
                // Show loading screen while attempting auto-login
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Signing you in...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                // Always show home screen, use example user if not authenticated
                HomePageView(
                    isLoggedIn: .constant(authManager.isAuthenticated),
                    user: authManager.currentUser ?? User.exampleUser
                )
            }
        }
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
    @StateObject private var goalCalendar = GoalCalendarViewModel()
    
//    hardcoded data used to mimic returned request ============
    
    let user: User
    @State private var goals: [Goal] = Goal.exampleGoals
    @State private var fitnessRecords: [FitnessRecord] = FitnessRecord.exampleRecords                                                                           
    @State private var foods: [FoodEntry] = FoodEntry.exampleFoodEntries
    
//  ============================================================
    
    var body: some View {
        VStack(spacing: 0) {
            // Show different views based on selected tab
            if selectedTab == .workout {
                WorkoutPlanView()
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
            
//          MARK: GOAL BAR ============
            
            // MARK: Goals Horizontal Scroll
            Text("Goals")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if goalCalendar.isLoading {
                ProgressView("Loading goals...")
                    .padding(.horizontal)
            } else if let error = goalCalendar.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.horizontal)
//            } else if goalCalendar.currentWeekGoals.isEmpty {
//                Text("No goals for this week.")
//                    .foregroundColor(.secondary)
//                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(goalCalendar.allGoals) { goal in
                            GoalTileView(goal: goal, color: .blue)
                                .frame(width: 280) // consistent width for each tile
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
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
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .task {
                goalCalendar.loadGoals()
            }
        }
    }
}

#Preview {
    HomePageView(isLoggedIn: .constant(true), user: .exampleUser)
}
