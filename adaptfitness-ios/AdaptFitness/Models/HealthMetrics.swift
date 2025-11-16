//
//  HealthMetrics.swift
//  AdaptFitness
//
//  Health Metrics model matching backend API response
//
//  This file defines the data models used for health metrics:
//  - HealthMetrics: Complete model with all raw and calculated fields
//  - CalculatedHealthMetrics: Simplified response for calculations endpoint
//  - CreateHealthMetricsDto: Request DTO for creating new entries
//

import Foundation

/// Health Metrics model with all calculated fields from backend
///
/// This struct represents a complete health metrics entry including:
/// - Raw input measurements (weight, body fat, circumferences)
/// - Calculated metrics from backend (BMI, TDEE, RMR, ratios, etc.)
/// - Computed properties for formatted display
///
/// All calculations are performed by the backend API to ensure accuracy
/// and consistency with medical formulas.
struct HealthMetrics: Codable, Identifiable {
    // MARK: - Basic Identifiers
    
    /// Unique identifier for this health metrics entry
    let id: Int
    
    /// User ID that owns this health metrics entry
    let userId: String
    
    // MARK: - Required Input Fields
    
    /// Current weight in kilograms (required field)
    /// This is the only required field when creating a new entry
    let currentWeight: Double
    
    // MARK: - Optional Input Fields
    
    /// Goal weight in kilograms (optional)
    /// Used for calculating calorie deficit and progress tracking
    let goalWeight: Double?
    
    /// Body fat percentage (optional, 0-100)
    /// Used in body composition calculations
    let bodyFatPercentage: Double?
    
    /// Water percentage of body weight (optional, 0-100)
    /// Used in hydration tracking
    let waterPercentage: Double?
    
    // MARK: - Body Measurements (Optional)
    // All measurements are in centimeters and optional
    // These are used to calculate health ratios like waist-to-hip ratio
    
    /// Waist circumference in centimeters
    let waistCircumference: Double?
    
    /// Hip circumference in centimeters
    let hipCircumference: Double?
    
    /// Chest circumference in centimeters
    let chestCircumference: Double?
    
    /// Thigh circumference in centimeters
    let thighCircumference: Double?
    
    /// Arm circumference in centimeters
    let armCircumference: Double?
    
    /// Neck circumference in centimeters
    let neckCircumference: Double?
    
    // MARK: - Calculated Metrics (from backend)
    // These values are calculated by the backend API using medical formulas
    // They are optional because some require additional user profile data (like height)
    
    /// Body Mass Index (BMI)
    /// Calculated as: weight (kg) / (height (m))²
    /// Categories: <18.5 Underweight, 18.5-25 Normal, 25-30 Overweight, >30 Obese
    let bmi: Double?
    
    /// Resting Metabolic Rate (RMR) in kcal/day
    /// The number of calories burned at rest
    /// Calculated using Mifflin-St Jeor equation
    let rmr: Double?
    
    /// Total Daily Energy Expenditure (TDEE) in kcal/day
    /// The total calories burned per day including activity
    /// Calculated as: RMR × Physical Activity Level multiplier
    let tdee: Double?
    
    /// Lean Body Mass in kilograms
    /// Total body weight minus fat mass
    let leanBodyMass: Double?
    
    /// Skeletal Muscle Mass in kilograms
    /// The amount of muscle tissue in the body
    let skeletalMuscleMass: Double?
    
    /// Waist-to-Hip Ratio
    /// Calculated as: waist circumference / hip circumference
    /// Health indicator for cardiovascular risk
    let waistToHipRatio: Double?
    
    /// Waist-to-Height Ratio
    /// Calculated as: waist circumference / height
    /// Alternative health indicator
    let waistToHeightRatio: Double?
    
    /// A Body Shape Index (ABSI)
    /// A measure of abdominal obesity
    /// Calculated using waist circumference, BMI, and height
    let absi: Double?
    
    /// Calorie Deficit in kcal/day
    /// The difference between TDEE and calories needed for goal weight
    let calorieDeficit: Double?
    
    /// Maximum Safe Fat Loss in kg/week
    /// The recommended maximum rate of fat loss per week for safety
    let maximumFatLoss: Double?
    
    /// Physical Activity Level multiplier
    /// Used in TDEE calculation (e.g., 1.2 sedentary, 1.55 moderately active)
    let physicalActivityLevel: Double?
    
    // MARK: - Metadata
    
    /// Optional notes or comments about this entry
    let notes: String?
    
    /// ISO 8601 formatted timestamp when entry was created
    let createdAt: String
    
    /// ISO 8601 formatted timestamp when entry was last updated
    let updatedAt: String
    
    // MARK: - Computed Properties for Display
    // These properties format the raw values for user-friendly display in the UI
    
    /// BMI category string based on BMI value
    /// Returns: "Underweight", "Normal weight", "Overweight", "Obese", or "N/A"
    /// Handles NaN values from backend (when height is missing)
    var bmiCategory: String {
        guard let bmi = bmi, bmi.isFinite, !bmi.isNaN else { return "N/A" }
        if bmi < 18.5 { return "Underweight" }
        if bmi < 25 { return "Normal weight" }
        if bmi < 30 { return "Overweight" }
        return "Obese"
    }
    
    /// Formatted BMI string with 1 decimal place
    /// Example: "23.4" or "N/A" if not available
    /// Handles NaN values from backend (when height is missing)
    var formattedBMI: String {
        guard let bmi = bmi, bmi.isFinite, !bmi.isNaN else { return "N/A" }
        return String(format: "%.1f", bmi)
    }
    
    /// Formatted TDEE string with no decimal places (whole number)
    /// Example: "2555" or "N/A" if not available
    var formattedTDEE: String {
        guard let tdee = tdee else { return "N/A" }
        return String(format: "%.0f", tdee)
    }
    
    /// Formatted RMR string with no decimal places (whole number)
    /// Example: "1648" or "N/A" if not available
    var formattedRMR: String {
        guard let rmr = rmr else { return "N/A" }
        return String(format: "%.0f", rmr)
    }
    
    /// Formatted waist-to-hip ratio with 2 decimal places
    /// Example: "0.84" or "N/A" if not available
    var formattedWaistToHipRatio: String {
        guard let ratio = waistToHipRatio else { return "N/A" }
        return String(format: "%.2f", ratio)
    }
    
    /// Formatted waist-to-height ratio with 3 decimal places
    /// Example: "0.457" or "N/A" if not available
    var formattedWaistToHeightRatio: String {
        guard let ratio = waistToHeightRatio else { return "N/A" }
        return String(format: "%.3f", ratio)
    }
    
    /// Formatted body fat percentage with 1 decimal place and % symbol
    /// Example: "15.0%" or "N/A" if not available
    var formattedBodyFatPercentage: String {
        guard let bodyFat = bodyFatPercentage else { return "N/A" }
        return String(format: "%.1f%%", bodyFat)
    }
    
    /// Formatted calorie deficit with no decimal places (whole number)
    /// Example: "500" or "N/A" if not available
    var formattedCalorieDeficit: String {
        guard let deficit = calorieDeficit else { return "N/A" }
        return String(format: "%.0f", deficit)
    }
}

/// Simplified calculated metrics response
///
/// This struct is returned by the `/health-metrics/calculations` endpoint
/// which provides only the calculated values without all the raw measurements.
/// Useful for quick lookups when you only need the computed metrics.
struct CalculatedHealthMetrics: Codable {
    let bmi: Double?
    let tdee: Double?
    let rmr: Double?
    let bodyFatCategory: String?
    let bmiCategory: String?
}

/// Request DTO for creating health metrics
///
/// This struct is used when sending POST requests to create a new health metrics entry.
/// Only `currentWeight` is required; all other fields are optional.
///
/// The backend will calculate all derived metrics (BMI, TDEE, RMR, ratios, etc.)
/// based on this input data and the user's profile information (height, age, gender, activity level).
struct CreateHealthMetricsDto: Codable {
    // MARK: - Required Fields
    
    /// Current weight in kilograms (required)
    let currentWeight: Double
    
    // MARK: - Optional Fields
    
    /// Body fat percentage (0-100)
    let bodyFatPercentage: Double?
    
    /// Goal weight in kilograms
    let goalWeight: Double?
    
    /// Water percentage (0-100)
    let waterPercentage: Double?
    
    // MARK: - Body Measurements (Optional, all in centimeters)
    
    let waistCircumference: Double?
    let hipCircumference: Double?
    let chestCircumference: Double?
    let thighCircumference: Double?
    let armCircumference: Double?
    let neckCircumference: Double?
    
    // MARK: - Notes
    
    /// Optional notes or comments
    let notes: String?
    
    // MARK: - Initializer
    
    /// Convenience initializer with default values for optional parameters
    /// All optional fields default to nil if not provided
    init(
        currentWeight: Double,
        bodyFatPercentage: Double? = nil,
        goalWeight: Double? = nil,
        waterPercentage: Double? = nil,
        waistCircumference: Double? = nil,
        hipCircumference: Double? = nil,
        chestCircumference: Double? = nil,
        thighCircumference: Double? = nil,
        armCircumference: Double? = nil,
        neckCircumference: Double? = nil,
        notes: String? = nil
    ) {
        self.currentWeight = currentWeight
        self.bodyFatPercentage = bodyFatPercentage
        self.goalWeight = goalWeight
        self.waterPercentage = waterPercentage
        self.waistCircumference = waistCircumference
        self.hipCircumference = hipCircumference
        self.chestCircumference = chestCircumference
        self.thighCircumference = thighCircumference
        self.armCircumference = armCircumference
        self.neckCircumference = neckCircumference
        self.notes = notes
    }
}

