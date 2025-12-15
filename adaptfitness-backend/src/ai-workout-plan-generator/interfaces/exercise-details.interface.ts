export interface ExerciseDbSearchResponse {
  success: boolean;
  data: {
    data: ExerciseSearchResult[];
    meta?: {
      total: number;
      hasNextPage: boolean;
      hasPreviousPage: boolean;
      nextCursor?: string;
    };
  };
}

export interface ExerciseSearchResult {
  exerciseId: string;
  name: string;
  imageUrl: string;
}

export interface ExerciseDetailsResponse {
  success: boolean;
  data: ExerciseDetailedInfo;
}

export interface ExerciseDetailedInfo {
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

export interface EnhancedSearchResult {
  success: boolean;
  data?: {
    data: ExerciseSearchResult[];
  };
  bestMatch?: ExerciseSearchResult & { matchScore?: number };
  strategyUsed?: string;
  searchTerm?: string;
  message: string;
  error?: string;
}
