//
//  WorkoutPlan.swift
//  AdaptFitness
//
//  AI-generated workout plan models
//

import Foundation

// MARK: - Workout Plan (Database Entity)
struct WorkoutPlan: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let description: String?
    let workoutPlanData: WorkoutPlanData
    let isActive: Bool
    let isCompleted: Bool
    let completedAt: String?
    let createdAt: String
    let updatedAt: String
}

// MARK: - Workout Plan Data (AI Generated Structure)
struct WorkoutPlanData: Codable {
    let planName: String
    let planDescription: String
    let days: [WorkoutDay]
    let enrichmentStats: EnrichmentStats?

    private enum CodingKeys: String, CodingKey {
        case planName = "plan_name"
        case planDescription = "plan_description"
        case days
        case enrichmentStats
    }
}

// MARK: - Workout Day
struct WorkoutDay: Codable, Identifiable {
    var id: Int { dayNumber }
    let dayNumber: Int
    let dayName: String
    let exercises: [ExercisePlan]

    private enum CodingKeys: String, CodingKey {
        case dayNumber = "day_number"
        case dayName = "day_name"
        case exercises
    }
}

// MARK: - Exercise Plan
struct ExercisePlan: Codable, Identifiable {
    var id: String { exerciseName }
    let exerciseName: String
    let sets: Int
    let reps: String
    let exerciseDetails: ExerciseDetails?
    let dataSource: String?
    let matchConfidence: String?
    let matchedExerciseName: String?
    let searchStrategy: String?

    private enum CodingKeys: String, CodingKey {
        case exerciseName = "exercise_name"
        case sets, reps
        case exerciseDetails, dataSource, matchConfidence
        case matchedExerciseName = "matched_exercise_name"
        case searchStrategy = "search_strategy"
    }
}

// MARK: - Exercise Details
struct ExerciseDetails: Codable {
    let exerciseId: String?
    let name: String?
    let imageUrl: String
    let videoUrl: String?
    let bodyParts: [String]
    let equipments: [String]
    let exerciseType: String?
    let targetMuscles: [String]
    let secondaryMuscles: [String]
    let keywords: [String]
    let overview: String?
    let instructions: [String]
    let exerciseTips: [String]
    let variations: [String]
    let relatedExerciseIds: [String]

    private enum CodingKeys: String, CodingKey {
        case exerciseId, name, imageUrl, videoUrl
        case bodyParts, equipments, exerciseType
        case targetMuscles, secondaryMuscles, keywords
        case overview, instructions, exerciseTips
        case variations, relatedExerciseIds
    }
    
    // Custom decoder to provide defaults for missing values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        exerciseId = try container.decodeIfPresent(String.self, forKey: .exerciseId)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        bodyParts = try container.decodeIfPresent([String].self, forKey: .bodyParts) ?? []
        equipments = try container.decodeIfPresent([String].self, forKey: .equipments) ?? []
        exerciseType = try container.decodeIfPresent(String.self, forKey: .exerciseType)
        targetMuscles = try container.decodeIfPresent([String].self, forKey: .targetMuscles) ?? []
        secondaryMuscles = try container.decodeIfPresent([String].self, forKey: .secondaryMuscles) ?? []
        keywords = try container.decodeIfPresent([String].self, forKey: .keywords) ?? []
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
        exerciseTips = try container.decodeIfPresent([String].self, forKey: .exerciseTips) ?? []
        variations = try container.decodeIfPresent([String].self, forKey: .variations) ?? []
        relatedExerciseIds = try container.decodeIfPresent([String].self, forKey: .relatedExerciseIds) ?? []
    }
    
    // Keep the memberwise initializer for testing/preview purposes
    init(
        exerciseId: String? = nil,
        name: String? = nil,
        imageUrl: String,
        videoUrl: String? = nil,
        bodyParts: [String] = [],
        equipments: [String] = [],
        exerciseType: String? = nil,
        targetMuscles: [String] = [],
        secondaryMuscles: [String] = [],
        keywords: [String] = [],
        overview: String? = nil,
        instructions: [String] = [],
        exerciseTips: [String] = [],
        variations: [String] = [],
        relatedExerciseIds: [String] = []
    ) {
        self.exerciseId = exerciseId
        self.name = name
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.bodyParts = bodyParts
        self.equipments = equipments
        self.exerciseType = exerciseType
        self.targetMuscles = targetMuscles
        self.secondaryMuscles = secondaryMuscles
        self.keywords = keywords
        self.overview = overview
        self.instructions = instructions
        self.exerciseTips = exerciseTips
        self.variations = variations
        self.relatedExerciseIds = relatedExerciseIds
    }
}

// MARK: - Enrichment Stats
struct EnrichmentStats: Codable {
    let totalExercises: Int
    let detailedEnriched: Int
    let searchEnriched: Int
    let aiOnly: Int
    let totalEnriched: Int
    let enrichmentRate: Double
    let highConfidenceMatches: Int
    let mediumConfidenceMatches: Int
    let noMatches: Int
    let highConfidenceRate: Double
}

// MARK: - Request DTOs
struct GenerateWorkoutPlanRequest: Codable {
    let userGoal: String
    let experienceLevel: String
    let daysPerWeek: Int
}

// MARK: - Response DTOs
struct GenerateAndSaveWorkoutPlanResponse: Codable {
    let success: Bool
    let data: WorkoutPlan
    let message: String
}

struct ActivePlanResponse: Codable {
    let data: WorkoutPlan?
}
