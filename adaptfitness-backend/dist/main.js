"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("./app.module");
const env_validation_1 = require("./config/env.validation");
async function bootstrap() {
    var _a;
    (0, env_validation_1.validateEnvironment)();
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.enableCors({
        origin: ((_a = process.env.CORS_ORIGIN) === null || _a === void 0 ? void 0 : _a.split(',')) || ['http://localhost:3000', 'http://localhost:8080'],
        credentials: true,
    });
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    }));
    const port = process.env.PORT || 3000;
    await app.listen(port);
    console.log(`🚀 AdaptFitness API running on port ${port}`);
    console.log(`📱 Health check: http://localhost:${port}/health`);
}
bootstrap();
//# sourceMappingURL=main.js.map