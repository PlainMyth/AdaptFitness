import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import {
  ExerciseDbSearchResponse,
  ExerciseSearchResult,
  ExerciseDetailsResponse,
  EnhancedSearchResult,
} from './interfaces/exercise-details.interface';
import { WorkoutPlan, EnrichmentStats } from './interfaces/workout-plan.interface';

@Injectable()
export class ExerciseDbService {
  private readonly logger = new Logger(ExerciseDbService.name);
  private readonly baseUrl = 'https://exercisedb-api1.p.rapidapi.com/api/v1';
  private readonly headers: Record<string, string>;

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
  ) {
    try {
      const apiKey = this.configService.get<string>('EXERCISEDB_API_KEY');
      if (!apiKey) {
        throw new Error('EXERCISEDB_API_KEY is not configured');
      }
      this.headers = {
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': 'exercisedb-api1.p.rapidapi.com',
      };
      this.logger.log('ExerciseDB service initialized successfully');
    } catch (error) {
      this.logger.error(`Failed to initialize ExerciseDB service: ${error.message}`);
      throw error;
    }
  }

  async testConnection(): Promise<{ success: boolean; message: string }> {
    try {
      const url = `${this.baseUrl}/liveness`;
      const response = await firstValueFrom(
        this.httpService.get(url, { headers: this.headers, timeout: 10000 }),
      );

      if (response.status === 200) {
        this.logger.log('ExerciseDB API connection test successful');
        return { success: true, message: 'API connection successful' };
      } else {
        this.logger.warn(`API connection test failed with status: ${response.status}`);
        return { success: false, message: `API returned status code: ${response.status}` };
      }
    } catch (error) {
      this.logger.error(`ExerciseDB API connection test failed: ${error.message}`);
      return { success: false, message: `Connection error: ${error.message}` };
    }
  }

  async searchExercises(searchTerm: string): Promise<ExerciseDbSearchResponse> {
    try {
      if (!searchTerm) {
        return {
          success: false,
          data: { data: [] },
        };
      }

      const url = `${this.baseUrl}/exercises/search`;
      const params = { search: searchTerm };

      const response = await firstValueFrom(
        this.httpService.get(url, {
          headers: this.headers,
          params,
          timeout: 15000,
        }),
      );

      if (response.status === 200) {
        this.logger.log(`Search for '${searchTerm}' returned ${response.data.data?.length || 0} results`);
        return {
          success: true,
          data: response.data,
        };
      } else {
        this.logger.warn(`Search failed. Status: ${response.status}`);
        return {
          success: false,
          data: { data: [] },
        };
      }
    } catch (error) {
      this.logger.error(`Request error during search: ${error.message}`);
      return {
        success: false,
        data: { data: [] },
      };
    }
  }

  async getExerciseById(exerciseId: string): Promise<ExerciseDetailsResponse> {
    try {
      if (!exerciseId) {
        return {
          success: false,
          data: null,
        };
      }

      const url = `${this.baseUrl}/exercises/${exerciseId}`;

      const response = await firstValueFrom(
        this.httpService.get(url, {
          headers: this.headers,
          timeout: 15000,
        }),
      );

      if (response.status === 200) {
        this.logger.log(`Successfully retrieved exercise details for ID: ${exerciseId}`);
        return {
          success: true,
          data: response.data.data || response.data,
        };
      } else if (response.status === 404) {
        this.logger.warn(`Exercise not found for ID: ${exerciseId}`);
        return {
          success: false,
          data: null,
        };
      } else {
        this.logger.warn(`Failed to get exercise by ID. Status: ${response.status}`);
        return {
          success: false,
          data: null,
        };
      }
    } catch (error) {
      this.logger.error(`Request error getting exercise by ID: ${error.message}`);
      return {
        success: false,
        data: null,
      };
    }
  }

  async enrichWorkoutPlan(
    workoutPlan: any,
  ): Promise<{ success: boolean; data?: any; enrichmentStats?: EnrichmentStats; message: string }> {
    try {
      if (!workoutPlan.success) {
        return {
          success: false,
          message: 'Workout plan must be successful to enrich',
        };
      }

      const planData = workoutPlan.data;
      const days = planData.days || [];

      const enrichedDays = [];

      for (const day of days) {
        const enrichedDay = { ...day };
        const exercises = day.exercises || [];
        const enrichedExercises = [];

        for (const exercise of exercises) {
          const exerciseName = exercise.exercise_name || exercise.exerciseName;

          // Enhanced search for exercise data
          const searchResult = await this.enhancedExerciseSearch(exerciseName);

          const enrichedExercise = { ...exercise };

          if (searchResult.success && searchResult.bestMatch) {
            const bestMatch = searchResult.bestMatch;
            const strategyUsed = searchResult.strategyUsed || 'unknown';
            const exerciseId = bestMatch.exerciseId;

            if (exerciseId) {
              this.logger.log(
                `Found match for '${exerciseName}' using ${strategyUsed} strategy: '${bestMatch.name}' (ID: ${exerciseId})`,
              );

              // Get detailed exercise information
              const detailedResult = await this.getExerciseById(exerciseId);

              if (detailedResult.success && detailedResult.data) {
                const detailedData = detailedResult.data;

                enrichedExercise.exerciseDetails = {
                  exerciseId: detailedData.exerciseId,
                  name: detailedData.name,
                  imageUrl: detailedData.imageUrl,
                  videoUrl: detailedData.videoUrl,
                  bodyParts: detailedData.bodyParts || [],
                  equipments: detailedData.equipments || [],
                  exerciseType: detailedData.exerciseType,
                  targetMuscles: detailedData.targetMuscles || [],
                  secondaryMuscles: detailedData.secondaryMuscles || [],
                  keywords: detailedData.keywords || [],
                  overview: detailedData.overview,
                  instructions: detailedData.instructions || [],
                  exerciseTips: detailedData.exerciseTips || [],
                  variations: detailedData.variations || [],
                  relatedExerciseIds: detailedData.relatedExerciseIds || [],
                };
                enrichedExercise.dataSource = 'exercisedb_api_detailed';
                enrichedExercise.matchConfidence = 'high';
                enrichedExercise.matchedExerciseName = detailedData.name;
                enrichedExercise.searchStrategy = strategyUsed;
                this.logger.log(`Successfully enriched '${exerciseName}' with detailed data`);
              } else {
                // Fallback to search data only
                enrichedExercise.exerciseDetails = {
                  exerciseId: bestMatch.exerciseId,
                  name: bestMatch.name,
                  imageUrl: bestMatch.imageUrl,
                  bodyParts: [],
                  equipments: [],
                  exerciseType: '',
                  targetMuscles: [],
                  secondaryMuscles: [],
                  keywords: [],
                  instructions: [],
                  exerciseTips: [],
                  variations: [],
                  relatedExerciseIds: [],
                };
                enrichedExercise.dataSource = 'exercisedb_api_search';
                enrichedExercise.matchConfidence = 'medium';
                enrichedExercise.matchedExerciseName = bestMatch.name;
                enrichedExercise.searchStrategy = strategyUsed;
                this.logger.warn(`Detailed fetch failed for '${exerciseName}', using search data only`);
              }
            } else {
              enrichedExercise.exerciseDetails = null;
              enrichedExercise.dataSource = 'ai_only';
              enrichedExercise.matchConfidence = 'none';
              enrichedExercise.searchStrategy = strategyUsed;
              this.logger.warn(`No exercise ID found for best match: '${exerciseName}'`);
            }
          } else {
            enrichedExercise.exerciseDetails = null;
            enrichedExercise.dataSource = 'ai_only';
            enrichedExercise.matchConfidence = 'none';
            enrichedExercise.searchStrategy = 'failed';
            this.logger.warn(
              `Enhanced search failed for exercise: '${exerciseName}' - ${searchResult.message}`,
            );
          }

          enrichedExercises.push(enrichedExercise);
        }

        enrichedDay.exercises = enrichedExercises;
        enrichedDays.push(enrichedDay);
      }

      const enrichedPlanData = { ...planData, days: enrichedDays };

      this.logger.log('Successfully enriched workout plan with exercise data');
      const enrichmentStats = this.getEnrichmentStats(enrichedDays);

      return {
        success: true,
        data: enrichedPlanData,
        enrichmentStats,
        message: 'Workout plan enriched with exercise database information',
      };
    } catch (error) {
      this.logger.error(`Error enriching workout plan: ${error.message}`, error.stack);
      return {
        success: false,
        message: 'Failed to enrich workout plan with exercise data',
      };
    }
  }

  private async enhancedExerciseSearch(exerciseName: string): Promise<EnhancedSearchResult> {
    try {
      if (!exerciseName || !exerciseName.trim()) {
        return {
          success: false,
          message: 'Exercise name cannot be empty',
        };
      }

      const searchStrategies: Array<{ name: string; term: string }> = [];

      // Strategy 1: Direct search with original name
      searchStrategies.push({ name: 'direct', term: exerciseName.trim() });

      // Strategy 2: Cleaned name
      const cleanedName = exerciseName
        .trim()
        .replace(/-/g, ' ')
        .replace(/_/g, ' ')
        .replace(/\s+/g, ' ');

      if (cleanedName !== exerciseName.trim()) {
        searchStrategies.push({ name: 'cleaned', term: cleanedName });
      }

      // Strategy 3: Individual significant words
      const words = cleanedName.split(' ').filter((word) => word.length > 2);
      if (words.length > 1) {
        for (const word of words) {
          searchStrategies.push({ name: 'word', term: word });
        }
      }

      // Strategy 4: Partial search (first + last word)
      if (words.length > 1) {
        const partialSearch = `${words[0]} ${words[words.length - 1]}`;
        if (partialSearch !== cleanedName) {
          searchStrategies.push({ name: 'partial', term: partialSearch });
        }
      }

      for (const strategy of searchStrategies) {
        this.logger.debug(
          `Trying ${strategy.name} search for '${exerciseName}' with term: '${strategy.term}'`,
        );

        const searchResult = await this.searchExercises(strategy.term);

        if (searchResult.success && searchResult.data?.data?.length > 0) {
          const exerciseData = searchResult.data.data;

          // Find best match using intelligent matching
          const bestMatch = this.findBestExerciseMatch(exerciseName, exerciseData);

          if (bestMatch) {
            this.logger.log(
              `Strategy '${strategy.name}' found ${exerciseData.length} results for '${exerciseName}'`,
            );
            return {
              success: true,
              data: searchResult.data,
              bestMatch,
              strategyUsed: strategy.name,
              searchTerm: strategy.term,
              message: `Found match using ${strategy.name} search`,
            };
          }
        }
      }

      this.logger.warn(`All search strategies failed for exercise: '${exerciseName}'`);
      return {
        success: false,
        message: `No exercises found matching '${exerciseName}'`,
      };
    } catch (error) {
      this.logger.error(`Error in enhanced exercise search for '${exerciseName}': ${error.message}`);
      return {
        success: false,
        error: `Search error: ${error.message}`,
        message: 'An error occurred during exercise search',
      };
    }
  }

  private findBestExerciseMatch(
    targetExerciseName: string,
    searchResults: ExerciseSearchResult[],
  ): (ExerciseSearchResult & { matchScore?: number }) | null {
    try {
      if (!searchResults || searchResults.length === 0 || !targetExerciseName) {
        return null;
      }

      const targetNameLower = targetExerciseName.toLowerCase().trim();
      const targetWords = new Set(targetNameLower.split(' '));

      let bestMatch: (ExerciseSearchResult & { matchScore?: number }) | null = null;
      let bestScore = 0;

      for (const exercise of searchResults) {
        const exerciseName = (exercise.name || '').toLowerCase().trim();
        const exerciseWords = new Set(exerciseName.split(' '));

        let score = 0;

        // 1. Exact match (highest priority)
        if (targetNameLower === exerciseName) {
          score += 100;
        }

        // 2. Exact substring match
        else if (targetNameLower.includes(exerciseName) || exerciseName.includes(targetNameLower)) {
          score += 80;
        }

        // 3. Word overlap scoring
        const commonWords = new Set([...targetWords].filter((word) => exerciseWords.has(word)));
        if (commonWords.size > 0) {
          const wordOverlapRatio = commonWords.size / Math.max(targetWords.size, exerciseWords.size);
          score += wordOverlapRatio * 60;
        }

        // 4. Partial word matching (for abbreviations, etc.)
        for (const targetWord of targetWords) {
          for (const exerciseWord of exerciseWords) {
            if (targetWord.length >= 3 && exerciseWord.length >= 3) {
              if (targetWord.includes(exerciseWord) || exerciseWord.includes(targetWord)) {
                score += 20;
              }
            }
          }
        }

        // 5. Character similarity
        if (targetNameLower.length > 0 && exerciseName.length > 0) {
          const charSimilarity = this.calculateStringSimilarity(targetNameLower, exerciseName);
          score += charSimilarity * 30;
        }

        // 6. Bonus for normalized matching
        const normalizedTarget = targetNameLower.replace(/-/g, ' ').replace(/_/g, ' ');
        const normalizedExercise = exerciseName.replace(/-/g, ' ').replace(/_/g, ' ');
        if (normalizedTarget === normalizedExercise) {
          score += 50;
        }

        this.logger.debug(`Exercise '${exerciseName}' scored ${score.toFixed(2)} for target '${targetExerciseName}'`);

        // Update best match if this exercise scores higher (minimum threshold: 30)
        if (score > bestScore && score >= 30) {
          bestScore = score;
          bestMatch = { ...exercise, matchScore: score };
        }
      }

      if (bestMatch) {
        this.logger.log(
          `Best match for '${targetExerciseName}': '${bestMatch.name}' (score: ${bestScore.toFixed(2)})`,
        );
      } else {
        this.logger.warn(
          `No suitable match found for '${targetExerciseName}' (best score: ${bestScore.toFixed(2)})`,
        );
      }

      return bestMatch;
    } catch (error) {
      this.logger.error(`Error finding best exercise match: ${error.message}`);
      return null;
    }
  }

  private calculateStringSimilarity(str1: string, str2: string): number {
    try {
      if (!str1 || !str2) {
        return 0.0;
      }

      if (str1 === str2) {
        return 1.0;
      }

      // Simple character overlap approach
      const set1 = new Set(str1.toLowerCase());
      const set2 = new Set(str2.toLowerCase());

      const intersection = new Set([...set1].filter((char) => set2.has(char)));
      const union = new Set([...set1, ...set2]);

      return union.size > 0 ? intersection.size / union.size : 0.0;
    } catch {
      return 0.0;
    }
  }

  private getEnrichmentStats(enrichedDays: any[]): EnrichmentStats {
    let totalExercises = 0;
    let detailedEnriched = 0;
    let searchEnriched = 0;
    let aiOnly = 0;

    let highConfidenceMatches = 0;
    let mediumConfidenceMatches = 0;
    let noMatches = 0;

    for (const day of enrichedDays) {
      const exercises = day.exercises || [];
      totalExercises += exercises.length;

      for (const exercise of exercises) {
        const dataSource = exercise.dataSource || 'ai_only';
        const matchConfidence = exercise.matchConfidence || 'none';

        // Count by data source
        if (dataSource === 'exercisedb_api_detailed') {
          detailedEnriched++;
        } else if (dataSource === 'exercisedb_api_search') {
          searchEnriched++;
        } else {
          aiOnly++;
        }

        // Count by match confidence
        if (matchConfidence === 'high') {
          highConfidenceMatches++;
        } else if (matchConfidence === 'medium') {
          mediumConfidenceMatches++;
        } else {
          noMatches++;
        }
      }
    }

    const totalEnriched = detailedEnriched + searchEnriched;
    const enrichmentRate = totalExercises > 0 ? (totalEnriched / totalExercises) * 100 : 0;
    const highConfidenceRate = totalExercises > 0 ? (highConfidenceMatches / totalExercises) * 100 : 0;

    return {
      totalExercises,
      detailedEnriched,
      searchEnriched,
      aiOnly,
      totalEnriched,
      enrichmentRate: Math.round(enrichmentRate * 100) / 100,
      highConfidenceMatches,
      mediumConfidenceMatches,
      noMatches,
      highConfidenceRate: Math.round(highConfidenceRate * 100) / 100,
    };
  }
}
