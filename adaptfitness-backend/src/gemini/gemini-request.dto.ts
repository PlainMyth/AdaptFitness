import { IsNotEmpty, IsString } from 'class-validator';

export class GeminiRequestDto {
  @IsString()
  @IsNotEmpty()
  prompt: string;
}
