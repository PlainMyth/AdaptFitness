import { Body, Controller, Post } from '@nestjs/common';
import { GeminiRequestDto } from './gemini-request.dto';

@Controller('gemini')
export class GeminiController {
  @Post()
  generate(@Body() body: GeminiRequestDto) {
    return {
      status: 'success',
      payload: {
        promptReceived: body.prompt,
      },
    };
  }
}
