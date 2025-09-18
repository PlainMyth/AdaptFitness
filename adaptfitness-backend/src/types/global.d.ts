/**
 * Global Type Declarations
 * 
 * This file helps TypeScript understand decorators and external libraries
 * that don't have complete type definitions.
 */

// Declare global types for decorators
declare global {
  // TypeORM decorators
  function Column(options?: any): PropertyDecorator;
  function Entity(name?: string): ClassDecorator;
  function PrimaryGeneratedColumn(): PropertyDecorator;
  function CreateDateColumn(): PropertyDecorator;
  function UpdateDateColumn(): PropertyDecorator;
  function ManyToOne(type: any, options?: any): PropertyDecorator;
  function OneToMany(type: any, inverseSide: any): PropertyDecorator;
  function JoinColumn(options?: any): PropertyDecorator;

  // NestJS decorators
  function Injectable(): ClassDecorator;
  function Controller(prefix?: string): ClassDecorator;
  function Get(path?: string): MethodDecorator;
  function Post(path?: string): MethodDecorator;
  function Put(path?: string): MethodDecorator;
  function Delete(path?: string): MethodDecorator;
  function Patch(path?: string): MethodDecorator;
  function Body(): ParameterDecorator;
  function Param(name: string): ParameterDecorator;
  function Query(name: string): ParameterDecorator;
  function Request(): ParameterDecorator;
  function UseGuards(...guards: any[]): MethodDecorator;

  // Validation decorators
  function IsString(options?: any): PropertyDecorator;
  function IsNumber(options?: any): PropertyDecorator;
  function IsEmail(options?: any): PropertyDecorator;
  function IsOptional(): PropertyDecorator;
  function Min(value: number): PropertyDecorator;
  function Max(value: number): PropertyDecorator;
  function Type(transformer: any): PropertyDecorator;

  // Jest testing globals
  const describe: jest.Describe;
  const it: jest.It;
  const test: jest.It;
  const expect: jest.Expect;
  const beforeEach: jest.Lifecycle;
  const afterEach: jest.Lifecycle;
  const beforeAll: jest.Lifecycle;
  const afterAll: jest.Lifecycle;
  const jest: typeof import('jest');
}

export {};
