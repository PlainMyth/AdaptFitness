//
//  HealthMetricsView.swift
//  AdaptFitness
//
//  Main view for displaying health metrics and calculated values
//
//  This view is the primary interface for viewing health metrics data.
//  It displays all calculated metrics in organized sections:
//  - Core Metrics: BMI, TDEE, RMR, Body Fat
//  - Body Composition: Lean Mass, Muscle Mass, Water Percentage
//  - Health Ratios: Waist-to-Hip, Waist-to-Height, ABSI
//  - Body Measurements: All circumference measurements
//  - Goals & Progress: Goal weight, calorie deficit, fat loss limits
//
//  The view handles three states:
//  1. Loading: Shows progress indicator while fetching data
//  2. Content: Shows all metrics in scrollable sections
//  3. Empty: Shows empty state when no metrics exist
//

import SwiftUI

/// Main view for displaying health metrics and calculated values
///
/// This view uses MVVM pattern with HealthMetricsViewModel to manage data.
/// It displays health metrics in organized sections with visual cards.
/// Supports pull-to-refresh and presents a sheet modal for adding new entries.
struct HealthMetricsView: View {
    // MARK: - State Management
    
    /// ViewModel managing health metrics data and API calls
    /// Uses @StateObject to create and own the ViewModel instance
    @StateObject private var viewModel = HealthMetricsViewModel()
    
    /// Controls visibility of the Add Health Metrics sheet modal
    /// Set to true when user taps "+" button or "Add Health Metrics"
    @State private var showingAddMetrics = false
    
    /// Environment value to dismiss the view when presented as a sheet
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Loading State
                // Show progress indicator while fetching data from API
                if viewModel.isLoading {
                    ProgressView("Loading health metrics...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                // MARK: - Content State
                // Display all metrics when data is available
                else if let metrics = viewModel.latestMetrics {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // MARK: - Core Metrics Section
                            // Displays the most important calculated metrics in a 2-column grid
                            // These are the primary health indicators: BMI, TDEE, RMR, Body Fat
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Core Metrics")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                                    StatCard(
                                        title: "BMI",
                                        value: metrics.formattedBMI,
                                        unit: metrics.bmiCategory,
                                        icon: "figure.stand",
                                        color: .red
                                    )
                                    
                                    StatCard(
                                        title: "TDEE",
                                        value: metrics.formattedTDEE,
                                        unit: "kcal/day",
                                        icon: "flame.fill",
                                        color: .orange
                                    )
                                    
                                    StatCard(
                                        title: "RMR",
                                        value: metrics.formattedRMR,
                                        unit: "kcal/day",
                                        icon: "bed.double.fill",
                                        color: .blue
                                    )
                                    
                                    if let bodyFat = metrics.bodyFatPercentage {
                                        StatCard(
                                            title: "Body Fat",
                                            value: String(format: "%.1f%%", bodyFat),
                                            unit: "percentage",
                                            icon: "circle.grid.cross.fill",
                                            color: .purple
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // MARK: - Body Composition Section
                            // Displays body composition metrics when available
                            // Shows lean body mass, skeletal muscle mass, and water percentage
                            // Only displays this section if at least one value exists
                            if metrics.leanBodyMass != nil || metrics.skeletalMuscleMass != nil {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Body Composition")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    VStack(spacing: 12) {
                                        if let leanMass = metrics.leanBodyMass {
                                            MeasurementRow(
                                                label: "Lean Body Mass",
                                                value: String(format: "%.1f kg", leanMass),
                                                icon: "scalemass.fill",
                                                color: .green
                                            )
                                        }
                                        
                                        if let muscleMass = metrics.skeletalMuscleMass {
                                            MeasurementRow(
                                                label: "Skeletal Muscle Mass",
                                                value: String(format: "%.1f kg", muscleMass),
                                                icon: "figure.strengthtraining.traditional",
                                                color: .blue
                                            )
                                        }
                                        
                                        if let water = metrics.waterPercentage {
                                            MeasurementRow(
                                                label: "Water Percentage",
                                                value: String(format: "%.1f%%", water),
                                                icon: "drop.fill",
                                                color: .cyan
                                            )
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // MARK: - Health Ratios Section
                            // Displays health risk indicator ratios
                            // Waist-to-Hip Ratio: cardiovascular risk indicator
                            // Waist-to-Height Ratio: alternative health indicator
                            // ABSI: A Body Shape Index for abdominal obesity
                            // Only displays this section if at least one ratio exists
                            if metrics.waistToHipRatio != nil || metrics.waistToHeightRatio != nil || metrics.absi != nil {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Health Ratios")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                                        if metrics.waistToHipRatio != nil {
                                            StatCard(
                                                title: "Waist-to-Hip",
                                                value: metrics.formattedWaistToHipRatio,
                                                unit: "ratio",
                                                icon: "ruler.fill",
                                                color: .indigo
                                            )
                                        }
                                        
                                        if metrics.waistToHeightRatio != nil {
                                            StatCard(
                                                title: "Waist-to-Height",
                                                value: metrics.formattedWaistToHeightRatio,
                                                unit: "ratio",
                                                icon: "arrow.up.and.down",
                                                color: .teal
                                            )
                                        }
                                    }
                                    
                                    if let absi = metrics.absi {
                                        MeasurementRow(
                                            label: "ABSI",
                                            value: String(format: "%.3f", absi),
                                            icon: "waveform.path",
                                            color: .pink
                                        )
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // MARK: - Body Measurements Section
                            // Displays all body circumference measurements in centimeters
                            // Shows: Waist, Hip, Chest, Arm, Thigh, Neck
                            // Only displays this section if at least one measurement exists
                            // Uses helper function to check if any measurements are available
                            if hasMeasurements(metrics) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Body Measurements")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    VStack(spacing: 12) {
                                        if let waist = metrics.waistCircumference {
                                            MeasurementRow(
                                                label: "Waist",
                                                value: String(format: "%.1f cm", waist),
                                                icon: "ruler.fill",
                                                color: .orange
                                            )
                                        }
                                        
                                        if let hip = metrics.hipCircumference {
                                            MeasurementRow(
                                                label: "Hip",
                                                value: String(format: "%.1f cm", hip),
                                                icon: "ruler.fill",
                                                color: .pink
                                            )
                                        }
                                        
                                        if let chest = metrics.chestCircumference {
                                            MeasurementRow(
                                                label: "Chest",
                                                value: String(format: "%.1f cm", chest),
                                                icon: "ruler.fill",
                                                color: .blue
                                            )
                                        }
                                        
                                        if let arm = metrics.armCircumference {
                                            MeasurementRow(
                                                label: "Arm",
                                                value: String(format: "%.1f cm", arm),
                                                icon: "ruler.fill",
                                                color: .green
                                            )
                                        }
                                        
                                        if let thigh = metrics.thighCircumference {
                                            MeasurementRow(
                                                label: "Thigh",
                                                value: String(format: "%.1f cm", thigh),
                                                icon: "ruler.fill",
                                                color: .purple
                                            )
                                        }
                                        
                                        if let neck = metrics.neckCircumference {
                                            MeasurementRow(
                                                label: "Neck",
                                                value: String(format: "%.1f cm", neck),
                                                icon: "ruler.fill",
                                                color: .gray
                                            )
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // MARK: - Goals & Progress Section
                            // Displays goal-related metrics and progress tracking
                            // Shows: Goal Weight, Current Weight, Calorie Deficit, Max Safe Fat Loss
                            // Only displays this section if at least one goal-related value exists
                            if metrics.goalWeight != nil || metrics.calorieDeficit != nil || metrics.maximumFatLoss != nil {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Goals & Progress")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    VStack(spacing: 12) {
                                        if let goalWeight = metrics.goalWeight {
                                            MeasurementRow(
                                                label: "Goal Weight",
                                                value: String(format: "%.1f kg", goalWeight),
                                                icon: "target",
                                                color: .blue
                                            )
                                            
                                            MeasurementRow(
                                                label: "Current Weight",
                                                value: String(format: "%.1f kg", metrics.currentWeight),
                                                icon: "scalemass.fill",
                                                color: .gray
                                            )
                                        }
                                        
                                        if metrics.calorieDeficit != nil {
                                            MeasurementRow(
                                                label: "Calorie Deficit",
                                                value: "\(metrics.formattedCalorieDeficit) kcal",
                                                icon: "minus.circle.fill",
                                                color: .red
                                            )
                                        }
                                        
                                        if let maxLoss = metrics.maximumFatLoss {
                                            MeasurementRow(
                                                label: "Max Safe Fat Loss",
                                                value: String(format: "%.2f kg/week", maxLoss),
                                                icon: "arrow.down.circle.fill",
                                                color: .orange
                                            )
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
                // MARK: - Empty State
                // Displayed when user has no health metrics entries yet
                // Provides guidance and button to create first entry
                else {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Health Metrics Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start tracking your health by adding your first metrics entry!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Add Health Metrics") {
                            showingAddMetrics = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            // MARK: - Navigation and Toolbar
            .navigationTitle("Health Metrics")
            .toolbar {
                // Done button to dismiss when presented as sheet
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                // Add button in navigation bar to open Add Health Metrics sheet
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddMetrics = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // MARK: - Sheet Modal for Adding Metrics
            // Presents AddHealthMetricsView as a sheet when user taps add button
            // The closure receives the created DTO and handles saving
            .sheet(isPresented: $showingAddMetrics) {
                AddHealthMetricsView { newMetrics in
                    // Create new entry via ViewModel
                    Task {
                        do {
                            // Create entry with backend API call
                            try await viewModel.createMetrics(newMetrics)
                            // Refresh to show newly created entry
                            await viewModel.fetchLatest()
                        } catch {
                            // Error handling is done in ViewModel
                            // ViewModel updates showError and errorMessage automatically
                        }
                    }
                }
            }
            // MARK: - Error Alert
            // Displays error alert when API calls fail
            // Triggered by ViewModel's showError published property
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            // MARK: - Lifecycle
            // Fetch data when view appears
            .onAppear {
                Task {
                    await viewModel.fetchLatest()
                }
            }
            // MARK: - Pull-to-Refresh
            // Enable pull-to-refresh gesture to reload data
            .refreshable {
                await viewModel.refreshMetrics()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Check if health metrics entry has any body measurements
    ///
    /// Used to conditionally show the Body Measurements section.
    /// Returns true if at least one circumference measurement exists.
    ///
    /// - Parameter metrics: The HealthMetrics object to check
    /// - Returns: true if any measurement exists, false otherwise
    private func hasMeasurements(_ metrics: HealthMetrics) -> Bool {
        return metrics.waistCircumference != nil ||
               metrics.hipCircumference != nil ||
               metrics.chestCircumference != nil ||
               metrics.armCircumference != nil ||
               metrics.thighCircumference != nil ||
               metrics.neckCircumference != nil
    }
}

/// Reusable component for displaying a measurement row
///
/// Shows a label, value, and icon in a horizontal row layout.
/// Used in Body Composition, Measurements, and Goals sections.
///
/// Example usage:
/// ```
/// MeasurementRow(
///     label: "Lean Body Mass",
///     value: "55.2 kg",
///     icon: "scalemass.fill",
///     color: .green
/// )
/// ```
struct MeasurementRow: View {
    /// Text label for the measurement (e.g., "Lean Body Mass")
    let label: String
    
    /// Formatted value to display (e.g., "55.2 kg")
    let value: String
    
    /// SF Symbol name for the icon
    let icon: String
    
    /// Color for the icon
    let color: Color
    
    var body: some View {
        HStack {
            // Icon on the left with fixed width for alignment
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            // Label text
            Text(label)
                .font(.body)
            
            Spacer()
            
            // Value text (right-aligned, bold)
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HealthMetricsView()
}

