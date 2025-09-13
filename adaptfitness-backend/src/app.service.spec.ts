import { Test, TestingModule } from '@nestjs/testing';
import { AppService } from './app.service';

describe('AppService', () => {
  let service: AppService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AppService],
    }).compile();

    service = module.get<AppService>(AppService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return health status', () => {
    const health = service.getHealth();
    expect(health).toHaveProperty('status', 'ok');
    expect(health).toHaveProperty('service', 'AdaptFitness API');
    expect(health).toHaveProperty('version', '1.0.0');
  });

  it('should return welcome message', () => {
    const welcome = service.getWelcome();
    expect(welcome).toHaveProperty('message', 'Welcome to AdaptFitness API');
    expect(welcome).toHaveProperty('endpoints');
  });
});
