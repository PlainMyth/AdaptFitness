//
//  Main.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/17/25.
//

import SwiftUI

struct HomePageView: View {
    @Binding var isLoggedIn: Bool
    public var streak: Int = 1
    
    private let weekDays = generateCurrentWeek()
    
    var body: some View {
        VStack {
            // Header with streak
            HStack {
                Spacer()
                
                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill") // fire icon
                        .foregroundColor(.orange)
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("\(streak)") // hardcoded streak number
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
            
            // Donut Graphs (placeholders)
//            HStack(spacing: 20) {
//                DonutStat(label: "Walking", value: "4.2 km left")
//                DonutStat(label: "Jan Avg", value: "1199 cal")
//                DonutStat(label: "Stretching", value: "16 left")
//                DonutStat(label: "Workout Days", value: "3 left")
//            }
            
            // Hor Calendar
            HStack(spacing: 10) {
                // where calendarview thing would go
                HorizontalCalendar(days: weekDays)
            }
            .padding(.horizontal)
            
            // Goals
            VStack {
                Text("Your goals")
                    .font(.title2)
                    .padding(.top, 30)
                
                Button(action: {
                    print("Add new goal tapped")
                }) {
                    Text("Add new")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
            }
            
            // Entries
            ScrollView {
                VStack(spacing: 20) {
                    EntryRow(date: "01/01", images: ["garbanzo", "garbanzo2", "garbanzo3"])
                    EntryRow(date: "01/02", images: ["chicken", "chicken2", "chicken3"])
                }
                .padding(.top, 20)
            }
            
            // Footer Tabs
            FooterTabBar()
            
        }
    }
}

struct DonutStat: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Circle()
                .strokeBorder(Color.gray, lineWidth: 5)
                .frame(width: 70, height: 70)
            
            VStack {
                Text(label)
                    .font(.caption)
                Text(value)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EntryRow: View {
    let date: String
    let images: [String]
    
    var body: some View {
        HStack {
            Text(date)
                .font(.headline)
                .frame(width: 60)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images, id: \.self) { image in
                        Image(image) // must be in Assets.xcassets
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// Preview
struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(isLoggedIn: .constant(true))
    }
}
