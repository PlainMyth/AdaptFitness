export interface GeminiResponse {
  success: boolean;
  data?: any;
  error?: string;
  partial?: boolean;
}

export interface GeminiGenerationConfig {
  responseMimeType: string;
  maxOutputTokens: number;
  temperature: number;
}
