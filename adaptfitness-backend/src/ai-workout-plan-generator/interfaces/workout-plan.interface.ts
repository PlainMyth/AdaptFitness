export interface WorkoutPlan {
  planName: string;
  planDescription: string;
  days: WorkoutDay[];
}

export interface WorkoutDay {
  dayNumber: number;
  dayName: string;
  exercises: Exercise[];
}

export interface Exercise {
  exerciseName: string;
  sets: number;
  reps: string;
  exerciseDetails?: ExerciseDetails;
  dataSource?: 'exercisedb_api_detailed' | 'exercisedb_api_search' | 'ai_only';
  matchConfidence?: 'high' | 'medium' | 'none';
  searchStrategy?: string;
}

export interface ExerciseDetails {
  exerciseId: string;
  name: string;
  imageUrl: string;
  videoUrl?: string;
  bodyParts: string[];
  equipments: string[];
  exerciseType: string;
  targetMuscles: string[];
  secondaryMuscles: string[];
  keywords: string[];
  overview?: string;
  instructions: string[];
  exerciseTips: string[];
  variations: string[];
  relatedExerciseIds: string[];
}

export interface EnrichmentStats {
  totalExercises: number;
  detailedEnriched: number;
  searchEnriched: number;
  aiOnly: number;
  totalEnriched: number;
  enrichmentRate: number;
  highConfidenceMatches: number;
  mediumConfidenceMatches: number;
  noMatches: number;
  highConfidenceRate: number;
}
