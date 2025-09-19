import { validate } from 'class-validator';
import { plainToClass } from 'class-transformer';
import { CreateHealthMetricsDto } from './create-health-metrics.dto';

describe('CreateHealthMetricsDto', () => {
  it('should be valid with required fields', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(0);
  });

  it('should be valid with all fields', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      bodyFatPercentage: 15,
      goalWeight: 65,
      waterPercentage: 60,
      waistCircumference: 80,
      hipCircumference: 95,
      chestCircumference: 100,
      thighCircumference: 60,
      armCircumference: 35,
      neckCircumference: 40,
      notes: 'Test measurement',
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(0);
  });

  it('should fail validation when currentWeight is missing', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      bodyFatPercentage: 15,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('currentWeight');
  });

  it('should fail validation when currentWeight is not a number', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 'not-a-number',
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('currentWeight');
  });

  it('should fail validation when bodyFatPercentage is greater than 100', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      bodyFatPercentage: 150,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('bodyFatPercentage');
    expect(errors[0].constraints).toHaveProperty('max');
  });

  it('should fail validation when bodyFatPercentage is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      bodyFatPercentage: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('bodyFatPercentage');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when waterPercentage is greater than 100', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      waterPercentage: 150,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('waterPercentage');
    expect(errors[0].constraints).toHaveProperty('max');
  });

  it('should fail validation when waterPercentage is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      waterPercentage: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('waterPercentage');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when goalWeight is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      goalWeight: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('goalWeight');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when waistCircumference is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      waistCircumference: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('waistCircumference');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when hipCircumference is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      hipCircumference: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('hipCircumference');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when chestCircumference is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      chestCircumference: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('chestCircumference');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when thighCircumference is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      thighCircumference: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('thighCircumference');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when armCircumference is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      armCircumference: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('armCircumference');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when neckCircumference is negative', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      neckCircumference: -10,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('neckCircumference');
    expect(errors[0].constraints).toHaveProperty('min');
  });

  it('should fail validation when notes is not a string', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 70,
      notes: 123,
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('notes');
    expect(errors[0].constraints).toHaveProperty('isString');
  });

  it('should pass validation with valid edge case values', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 0.1, // Very small weight
      bodyFatPercentage: 0, // Minimum body fat
      waterPercentage: 0, // Minimum water percentage
      goalWeight: 0.1, // Very small goal weight
      waistCircumference: 0.1, // Very small circumference
      hipCircumference: 0.1,
      chestCircumference: 0.1,
      thighCircumference: 0.1,
      armCircumference: 0.1,
      neckCircumference: 0.1,
      notes: '', // Empty string
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(0);
  });

  it('should pass validation with maximum valid values', async () => {
    const dto = plainToClass(CreateHealthMetricsDto, {
      currentWeight: 1000, // Very large weight
      bodyFatPercentage: 100, // Maximum body fat
      waterPercentage: 100, // Maximum water percentage
      goalWeight: 1000, // Very large goal weight
      waistCircumference: 1000, // Very large circumference
      hipCircumference: 1000,
      chestCircumference: 1000,
      thighCircumference: 1000,
      armCircumference: 1000,
      neckCircumference: 1000,
      notes: 'A'.repeat(1000), // Very long string
    });

    const errors = await validate(dto);
    expect(errors).toHaveLength(0);
  });
});
