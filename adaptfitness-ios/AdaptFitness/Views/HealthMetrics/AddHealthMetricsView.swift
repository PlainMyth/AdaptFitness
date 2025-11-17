//
//  AddHealthMetricsView.swift
//  AdaptFitness
//
//  Form view for adding new health metrics entry
//
//  This view presents a form for users to input health metrics data.
//  Only currentWeight is required; all other fields are optional.
//  The form validates input before allowing submission.
//  Upon save, creates a CreateHealthMetricsDto and calls the onSave closure.
//

import SwiftUI

/// Form view for adding new health metrics entry
///
/// This view provides a structured form with sections for:
/// - Required fields (current weight only)
/// - Body composition (body fat, water, goal weight)
/// - Body measurements (all circumferences in cm)
/// - Notes (optional text)
///
/// Form validation ensures currentWeight is valid (0-500 kg) before enabling save.
/// All optional fields are converted from String to Double (or nil if empty).
struct AddHealthMetricsView: View {
    // MARK: - Environment
    
    /// Environment value to dismiss this sheet modal
    /// Provided by SwiftUI when view is presented as a sheet
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    
    /// Closure called when user saves the form
    /// Receives the CreateHealthMetricsDto with all entered values
    /// Caller is responsible for sending to API via ViewModel
    let onSave: (CreateHealthMetricsDto) -> Void
    
    // MARK: - Form State
    // All fields are stored as String for TextField binding
    // Converted to Double when creating the DTO
    
    /// Current weight input (required)
    /// Must be valid number between 0-500 kg
    @State private var currentWeight: String = ""
    
    /// Body fat percentage input (optional, 0-100)
    @State private var bodyFatPercentage: String = ""
    
    /// Goal weight input (optional)
    @State private var goalWeight: String = ""
    
    /// Water percentage input (optional, 0-100)
    @State private var waterPercentage: String = ""
    
    // MARK: - Body Measurements State
    // All measurements are optional and in centimeters
    
    @State private var waistCircumference: String = ""
    @State private var hipCircumference: String = ""
    @State private var chestCircumference: String = ""
    @State private var thighCircumference: String = ""
    @State private var armCircumference: String = ""
    @State private var neckCircumference: String = ""
    
    // MARK: - Notes and Error State
    
    /// Optional notes text input
    @State private var notes: String = ""
    
    /// Flag to show error alert
    @State private var showingError = false
    
    /// Error message to display in alert
    @State private var errorMessage = ""
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Required Section
                // Only currentWeight is required
                Section(header: Text("Required")) {
                    TextField("Current Weight (kg)", text: $currentWeight)
                        .keyboardType(.decimalPad) // Show numeric keypad
                }
                
                // MARK: - Body Composition Section
                // Optional fields for body composition tracking
                Section(header: Text("Body Composition")) {
                    TextField("Body Fat Percentage (%)", text: $bodyFatPercentage)
                        .keyboardType(.decimalPad)
                    
                    TextField("Water Percentage (%)", text: $waterPercentage)
                        .keyboardType(.decimalPad)
                    
                    TextField("Goal Weight (kg)", text: $goalWeight)
                        .keyboardType(.decimalPad)
                }
                
                // MARK: - Body Measurements Section
                // All circumference measurements in centimeters
                // Used for calculating health ratios (waist-to-hip, etc.)
                Section(header: Text("Body Measurements (cm)")) {
                    TextField("Waist Circumference", text: $waistCircumference)
                        .keyboardType(.decimalPad)
                    
                    TextField("Hip Circumference", text: $hipCircumference)
                        .keyboardType(.decimalPad)
                    
                    TextField("Chest Circumference", text: $chestCircumference)
                        .keyboardType(.decimalPad)
                    
                    TextField("Arm Circumference", text: $armCircumference)
                        .keyboardType(.decimalPad)
                    
                    TextField("Thigh Circumference", text: $thighCircumference)
                        .keyboardType(.decimalPad)
                    
                    TextField("Neck Circumference", text: $neckCircumference)
                        .keyboardType(.decimalPad)
                }
                
                // MARK: - Notes Section
                // Optional text notes for this entry
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100) // Fixed height for text editor
                }
            }
            .navigationTitle("Add Health Metrics")
            .navigationBarTitleDisplayMode(.inline) // Compact title style
            .toolbar {
                // Cancel button to dismiss without saving
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // Save button - disabled if form validation fails
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMetrics()
                    }
                    .disabled(!isFormValid) // Disable if validation fails
                }
            }
            // MARK: - Error Alert
            // Shows validation error if save fails
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Validation
    
    /// Check if form is valid for submission
    ///
    /// Validates that currentWeight:
    /// - Is not empty
    /// - Can be converted to Double
    /// - Is greater than 0 (prevents negative values)
    /// - Is less than or equal to 500 kg (reasonable upper limit)
    ///
    /// - Returns: true if form is valid, false otherwise
    private var isFormValid: Bool {
        // Check if weight field is not empty
        guard !currentWeight.isEmpty else {
            return false
        }
        // Validate weight is a valid number in acceptable range
        guard let weight = Double(currentWeight), weight > 0, weight <= 500 else {
            return false
        }
        return true
    }
    
    // MARK: - Actions
    
    /// Save the form data and create DTO
    ///
    /// Validates currentWeight again (double-check before saving).
    /// Converts all String inputs to Double (or nil if empty).
    /// Creates CreateHealthMetricsDto and calls onSave closure.
    /// Dismisses the sheet modal after saving.
    private func saveMetrics() {
        // Validate currentWeight before proceeding
        guard !currentWeight.isEmpty else {
            errorMessage = "Please enter your current weight"
            showingError = true
            return
        }
        guard let weight = Double(currentWeight), weight > 0, weight <= 500 else {
            errorMessage = "Please enter a valid current weight (greater than 0 and up to 500 kg)"
            showingError = true
            return
        }
        
        // Create DTO with all entered values
        // Optional fields convert to Double if string is not empty, otherwise nil
        // Double("") returns nil, which is what we want for optional fields
        let dto = CreateHealthMetricsDto(
            currentWeight: weight,
            bodyFatPercentage: bodyFatPercentage.isEmpty ? nil : Double(bodyFatPercentage),
            goalWeight: goalWeight.isEmpty ? nil : Double(goalWeight),
            waterPercentage: waterPercentage.isEmpty ? nil : Double(waterPercentage),
            waistCircumference: waistCircumference.isEmpty ? nil : Double(waistCircumference),
            hipCircumference: hipCircumference.isEmpty ? nil : Double(hipCircumference),
            chestCircumference: chestCircumference.isEmpty ? nil : Double(chestCircumference),
            thighCircumference: thighCircumference.isEmpty ? nil : Double(thighCircumference),
            armCircumference: armCircumference.isEmpty ? nil : Double(armCircumference),
            neckCircumference: neckCircumference.isEmpty ? nil : Double(neckCircumference),
            notes: notes.isEmpty ? nil : notes // nil if empty, otherwise use string
        )
        
        // Call save closure (handled by parent view/ViewModel)
        onSave(dto)
        
        // Dismiss this sheet modal
        dismiss()
    }
}

#Preview {
    AddHealthMetricsView { _ in }
}

