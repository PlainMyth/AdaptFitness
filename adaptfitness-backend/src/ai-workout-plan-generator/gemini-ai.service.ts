import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } from '@google/generative-ai';
import { GeminiResponse, GeminiGenerationConfig } from './interfaces/gemini-response.interface';

@Injectable()
export class GeminiAiService {
  private readonly logger = new Logger(GeminiAiService.name);
  private readonly genAI: GoogleGenerativeAI;
  private readonly modelId = 'gemini-2.5-flash';

  constructor(private readonly configService: ConfigService) {
    try {
      const apiKey = this.configService.get<string>('GEMINI_API_KEY');
      if (!apiKey) {
        throw new Error('GEMINI_API_KEY is not configured');
      }
      this.genAI = new GoogleGenerativeAI(apiKey);
      this.logger.log('Gemini AI service initialized successfully');
    } catch (error) {
      this.logger.error(`Failed to initialize Gemini AI service: ${error.message}`);
      throw error;
    }
  }

  async testConnection(): Promise<{ success: boolean; message: string }> {
    try {
      const model = this.genAI.getGenerativeModel({ model: this.modelId });
      const result = await model.generateContent('Hello, are you working?');
      const response = await result.response;
      const text = response.text();

      this.logger.log('AI connection test successful');
      return { success: true, message: text };
    } catch (error) {
      this.logger.error(`AI connection test failed: ${error.message}`);
      return { success: false, message: error.message };
    }
  }

  async generateExercisePlan(
    userGoal: string,
    experienceLevel: string,
    daysPerWeek: number,
    userProfile: { age?: number; gender?: string; weight?: number; height?: number },
  ): Promise<GeminiResponse> {
    try {
      const prompt = this.createWorkoutPlanPrompt(userGoal, experienceLevel, daysPerWeek, userProfile);

      // Configure safety settings to be less restrictive for fitness content
      const safetySettings = [
        {
          category: HarmCategory.HARM_CATEGORY_HARASSMENT,
          threshold: HarmBlockThreshold.BLOCK_NONE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
          threshold: HarmBlockThreshold.BLOCK_NONE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
          threshold: HarmBlockThreshold.BLOCK_NONE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
          threshold: HarmBlockThreshold.BLOCK_NONE,
        },
      ];

      const generationConfig: GeminiGenerationConfig = {
        responseMimeType: 'application/json',
        maxOutputTokens: 16384, // Increased token limit for detailed workout plans
        temperature: 0.7,
      };

      const model = this.genAI.getGenerativeModel({
        model: this.modelId,
        safetySettings,
        generationConfig,
      });

      const result = await model.generateContent({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
      });

      const response = await result.response;
      const text = response.text();

      this.logger.log('Exercise plan generated successfully');
      return this.parseJsonResponse(text, 'exercise_plan');
    } catch (error) {
      this.logger.error(`Error generating exercise plan: ${error.message}`, error.stack);
      throw error;
    }
  }

  private createWorkoutPlanPrompt(
    userGoal: string,
    experienceLevel: string,
    daysPerWeek: number,
    userProfile: { age?: number; gender?: string; weight?: number; height?: number },
  ): string {
    // Example JSON structure for the AI to follow
    const jsonStructureExample = {
      plan_name: '4-Day Muscle Building Split',
      plan_description: 'A 4-day split designed to maximize muscle growth by targeting major muscle groups.',
      days: [
        {
          day_number: 1,
          day_name: 'Upper Body Strength',
          exercises: [
            {
              exercise_name: 'Bench Press',
              sets: 4,
              reps: '6-8',
            },
            {
              exercise_name: 'Bent Over Row',
              sets: 4,
              reps: '6-8',
            },
          ],
        },
      ],
    };

    const prompt = `
You are an expert fitness coach and personal trainer. Your task is to create a personalized, ${daysPerWeek}-day workout plan based on the user's profile and goals.

**User Profile:**
- Goal: ${userGoal}
- Experience Level: ${experienceLevel}
- Age: ${userProfile.age || 'Not provided'}
- Gender: ${userProfile.gender || 'Not provided'}

**Instructions:**
1. Create a logical weekly split appropriate for the user's goal and available days.
2. Select exercises that are effective and safe for the user's experience level.
3. Provide a clear number of sets and a target repetition range for each exercise.

**Output Format:**
You MUST format your response as a single, valid JSON object. Do not include any introductory text, explanations, or markdown formatting like \`\`\`json. Your entire response must be the JSON object itself, matching this exact structure:

${JSON.stringify(jsonStructureExample, null, 2)}
    `.trim();

    return prompt;
  }

  private parseJsonResponse(responseText: string, expectedType: string): GeminiResponse {
    try {
      // Clean up the response text
      let cleanedText = responseText.trim();

      // If response is truncated, try to fix common JSON issues
      if (!cleanedText.endsWith('}')) {
        this.logger.warn('Response appears truncated, attempting to fix JSON');

        // Count open braces vs close braces
        const openBraces = (cleanedText.match(/{/g) || []).length;
        const closeBraces = (cleanedText.match(/}/g) || []).length;
        const missingBraces = openBraces - closeBraces;

        // Add missing closing braces
        if (missingBraces > 0) {
          cleanedText += '}'.repeat(missingBraces);
          this.logger.log(`Added ${missingBraces} closing braces to fix JSON`);
        }
      }

      const parsedData = JSON.parse(cleanedText);
      this.logger.log(`Successfully parsed ${expectedType} response`);
      return { success: true, data: parsedData };
    } catch (error) {
      if (error instanceof SyntaxError) {
        this.logger.error(
          `JSON decode error for ${expectedType}: ${error.message}. Raw response: ${responseText.substring(0, 1000)}...`,
        );

        // Try to extract partial data if possible
        try {
          // Find the first complete object
          const startIdx = responseText.indexOf('{');
          if (startIdx !== -1) {
            // Try to find a reasonable cutoff point
            for (let endIdx = responseText.length - 1; endIdx > startIdx; endIdx--) {
              if (responseText[endIdx] === '}') {
                try {
                  const partialResponse = responseText.substring(startIdx, endIdx + 1);
                  const parsedData = JSON.parse(partialResponse);
                  this.logger.warn(`Successfully parsed partial ${expectedType} response`);
                  return { success: true, data: parsedData, partial: true };
                } catch {
                  continue;
                }
              }
            }
          }
        } catch (fallbackError) {
          this.logger.error(`Fallback parsing also failed: ${fallbackError.message}`);
        }

        return {
          success: false,
          error: `Failed to parse AI response as JSON: ${error.message}`,
        };
      }

      this.logger.error(`Unexpected error parsing ${expectedType}: ${error.message}`);
      return {
        success: false,
        error: `Unexpected error: ${error.message}`,
      };
    }
  }
}
