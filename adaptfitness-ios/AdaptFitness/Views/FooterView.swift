//
//  FooterView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/17/25.
//

import SwiftUI

struct FooterTabBar: View {
    @Binding var selectedTab: Tab
    @State private var showingProfile = false
    @StateObject private var authManager = AuthManager.shared
    
    enum Tab {
        case home, stats, calendar, browse
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: { selectedTab = .home }) {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 20))
                    Text("Home")
                        .font(.caption2)
                }
                .foregroundColor(selectedTab == .home ? .blue : .gray)
            }
            
            Spacer()
            
            Button(action: { selectedTab = .stats }) {
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                    Text("Stats")
                        .font(.caption2)
                }
                .foregroundColor(selectedTab == .stats ? .blue : .gray)
            }
            
            Spacer()
            
            Button(action: { selectedTab = .calendar }) {
                VStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                    Text("Calendar")
                        .font(.caption2)
                }
                .foregroundColor(selectedTab == .calendar ? .blue : .gray)
            }
            
            Spacer()
            
            Button(action: { selectedTab = .browse }) {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                    Text("Browse")
                        .font(.caption2)
                }
                .foregroundColor(selectedTab == .browse ? .blue : .gray)
            }
            
            Spacer()
            
            Button(action: { showingProfile = true }) {
                VStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                    Text("Profile")
                        .font(.caption2)
                }
                .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }

//        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
//        .shadow(radius: 3)
    }
}
