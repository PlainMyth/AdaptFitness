"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const app_service_1 = require("./app.service");
describe('AppService', () => {
    let service;
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            providers: [app_service_1.AppService],
        }).compile();
        service = module.get(app_service_1.AppService);
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
//# sourceMappingURL=app.service.spec.js.map