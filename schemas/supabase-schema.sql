-- =====================================================
-- UltimateFitness Supabase Database Schema
-- =====================================================
-- This script creates all tables, indexes, triggers, and functions
-- for the UltimateFitness application in Supabase PostgreSQL
--
-- Tables:
--   1. users - User accounts and profiles
--   2. workouts - Workout tracking
--   3. meals - Meal and nutrition logging
--   4. health_metrics - Body composition and health data
--   5. goal_calendars - Weekly fitness goals
--   6. workout_plans - AI-generated workout plans (NEW)
-- =====================================================

-- =====================================================
-- DROP EXISTING TABLES (CAUTION: This will delete all data!)
-- Uncomment the following section if you want to reset the database
-- =====================================================
/*
DROP TABLE IF EXISTS workout_plans CASCADE;
DROP TABLE IF EXISTS goal_calendars CASCADE;
DROP TABLE IF EXISTS health_metrics CASCADE;
DROP TABLE IF EXISTS meals CASCADE;
DROP TABLE IF EXISTS workouts CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
*/

-- =====================================================
-- TABLE 1: users
-- Stores user account information and profile data
-- =====================================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth TIMESTAMP NULL,
  height DECIMAL(5,2) NULL,  -- in cm
  weight DECIMAL(5,2) NULL,  -- in kg
  gender VARCHAR(20) NULL CHECK (gender IN ('male', 'female', 'other')),
  activity_level VARCHAR(50) NULL CHECK (activity_level IN ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active')),
  activity_level_multiplier DECIMAL(3,2) NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

COMMENT ON TABLE users IS 'User accounts and profile information';
COMMENT ON COLUMN users.height IS 'User height in centimeters';
COMMENT ON COLUMN users.weight IS 'User weight in kilograms';
COMMENT ON COLUMN users.activity_level_multiplier IS 'Multiplier for TDEE calculation (1.2, 1.375, 1.55, 1.725, 1.9)';

-- =====================================================
-- TABLE 2: workouts
-- Stores completed and scheduled workout sessions
-- =====================================================
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NULL,
  total_calories_burned DECIMAL(6,2) DEFAULT 0,
  total_duration INTEGER DEFAULT 0,  -- in minutes
  total_sets INTEGER DEFAULT 0,
  total_reps INTEGER DEFAULT 0,
  total_weight DECIMAL(6,2) DEFAULT 0,  -- in kg
  workout_type VARCHAR(50) NULL CHECK (workout_type IN ('strength', 'cardio', 'flexibility', 'sports', 'other')),
  is_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for workouts table
CREATE INDEX idx_workouts_user_id ON workouts(user_id);
CREATE INDEX idx_workouts_start_time ON workouts(start_time);
CREATE INDEX idx_workouts_workout_type ON workouts(workout_type);
CREATE INDEX idx_workouts_is_completed ON workouts(is_completed);
CREATE INDEX idx_workouts_user_start ON workouts(user_id, start_time);

COMMENT ON TABLE workouts IS 'Workout sessions and exercise tracking';
COMMENT ON COLUMN workouts.total_duration IS 'Workout duration in minutes';
COMMENT ON COLUMN workouts.total_weight IS 'Total weight lifted in kilograms';

-- =====================================================
-- TABLE 3: meals
-- Stores meal logs with nutritional information
-- =====================================================
CREATE TABLE meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  meal_time TIMESTAMPTZ NOT NULL,
  total_calories DECIMAL(6,2) DEFAULT 0,
  total_protein DECIMAL(6,2) DEFAULT 0,  -- in grams
  total_carbs DECIMAL(6,2) DEFAULT 0,    -- in grams
  total_fat DECIMAL(6,2) DEFAULT 0,      -- in grams
  total_fiber DECIMAL(6,2) DEFAULT 0,    -- in grams
  total_sugar DECIMAL(6,2) DEFAULT 0,    -- in grams
  total_sodium DECIMAL(6,2) DEFAULT 0,   -- in mg
  meal_type VARCHAR(50) NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'other')),
  serving_size DECIMAL(6,2) DEFAULT 0,
  serving_unit VARCHAR(50) NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for meals table
CREATE INDEX idx_meals_user_id ON meals(user_id);
CREATE INDEX idx_meals_meal_time ON meals(meal_time);
CREATE INDEX idx_meals_meal_type ON meals(meal_type);
CREATE INDEX idx_meals_user_time ON meals(user_id, meal_time);

COMMENT ON TABLE meals IS 'Meal logs with nutritional information';
COMMENT ON COLUMN meals.total_protein IS 'Protein content in grams';
COMMENT ON COLUMN meals.total_carbs IS 'Carbohydrate content in grams';
COMMENT ON COLUMN meals.total_fat IS 'Fat content in grams';
COMMENT ON COLUMN meals.total_sodium IS 'Sodium content in milligrams';

-- =====================================================
-- TABLE 4: health_metrics
-- Stores body composition and health data
-- =====================================================
CREATE TABLE health_metrics (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  -- Body Composition
  body_fat_percentage DECIMAL(5,2) NULL,
  lean_body_mass DECIMAL(5,2) NULL,
  skeletal_muscle_mass DECIMAL(5,2) NULL,
  current_weight DECIMAL(5,2) NOT NULL,
  goal_weight DECIMAL(5,2) NULL,
  water_percentage DECIMAL(5,2) NULL,
  -- Advanced Calculations
  absi DECIMAL(5,2) NULL,  -- A Body Shape Index
  maximum_fat_loss DECIMAL(5,2) NULL,
  calorie_deficit DECIMAL(6,2) NULL,
  -- Metabolic
  tdee DECIMAL(6,2) NULL,  -- Total Daily Energy Expenditure
  rmr DECIMAL(6,2) NULL,   -- Resting Metabolic Rate
  physical_activity_level DECIMAL(3,2) NULL,
  -- Body Measurements (in cm)
  waist_circumference DECIMAL(5,2) NULL,
  hip_circumference DECIMAL(5,2) NULL,
  chest_circumference DECIMAL(5,2) NULL,
  thigh_circumference DECIMAL(5,2) NULL,
  arm_circumference DECIMAL(5,2) NULL,
  neck_circumference DECIMAL(5,2) NULL,
  -- Calculated Ratios
  waist_to_hip_ratio DECIMAL(4,3) NULL,
  waist_to_height_ratio DECIMAL(4,3) NULL,
  bmi DECIMAL(4,2) NULL,
  -- Metadata
  notes TEXT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for health_metrics table
CREATE INDEX idx_health_metrics_user_id ON health_metrics(user_id);
CREATE INDEX idx_health_metrics_created_at ON health_metrics(created_at);

COMMENT ON TABLE health_metrics IS 'Body composition and health metrics tracking';
COMMENT ON COLUMN health_metrics.absi IS 'A Body Shape Index';
COMMENT ON COLUMN health_metrics.tdee IS 'Total Daily Energy Expenditure in calories';
COMMENT ON COLUMN health_metrics.rmr IS 'Resting Metabolic Rate in calories';

-- =====================================================
-- TABLE 5: goal_calendars
-- Stores weekly fitness goals and progress tracking
-- =====================================================
CREATE TABLE goal_calendars (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  week_end_date DATE NOT NULL,
  goal_type VARCHAR(50) NOT NULL CHECK (goal_type IN ('workouts_count', 'total_duration', 'total_calories', 'total_sets', 'total_reps', 'total_weight', 'streak_days')),
  target_value DECIMAL(10,2) NOT NULL,
  current_value DECIMAL(10,2) DEFAULT 0,
  completion_percentage DECIMAL(5,2) DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT false,
  description TEXT NULL,
  workout_type VARCHAR(50) NULL CHECK (workout_type IN ('strength', 'cardio', 'flexibility', 'sports', 'other')),
  progress_history JSONB NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for goal_calendars table
CREATE INDEX idx_goal_calendars_user_id ON goal_calendars(user_id);
CREATE INDEX idx_goal_calendars_week_dates ON goal_calendars(week_start_date, week_end_date);
CREATE INDEX idx_goal_calendars_is_active ON goal_calendars(is_active);
CREATE INDEX idx_goal_calendars_user_active ON goal_calendars(user_id, is_active);

COMMENT ON TABLE goal_calendars IS 'Weekly fitness goals and progress tracking';
COMMENT ON COLUMN goal_calendars.progress_history IS 'JSONB array storing daily progress snapshots';

-- =====================================================
-- TABLE 6: workout_plans (NEW)
-- Stores AI-generated workout plans for users
-- =====================================================
CREATE TABLE workout_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  workout_plan_data JSONB NOT NULL,  -- Stores the AI-generated plan structure
  is_completed BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for workout_plans table
CREATE INDEX idx_workout_plans_user_id ON workout_plans(user_id);
CREATE INDEX idx_workout_plans_is_active ON workout_plans(is_active);
CREATE INDEX idx_workout_plans_is_completed ON workout_plans(is_completed);
CREATE INDEX idx_workout_plans_created_at ON workout_plans(created_at);
CREATE INDEX idx_workout_plans_user_active ON workout_plans(user_id, is_active);

COMMENT ON TABLE workout_plans IS 'AI-generated workout plans';
COMMENT ON COLUMN workout_plans.workout_plan_data IS 'JSONB structure containing goal, experience level, age, gender, weekly schedule, exercises, and nutrition guidelines';

-- =====================================================
-- RECOMMENDED JSONB STRUCTURE for workout_plan_data:
-- =====================================================
-- {
--   "goal": "build_muscle",
--   "experience_level": "intermediate",
--   "age": 25,
--   "gender": "male",
--   "duration_weeks": 8,
--   "weekly_schedule": [
--     {
--       "day": "Monday",
--       "workout_type": "strength",
--       "exercises": [
--         {
--           "name": "Bench Press",
--           "sets": 4,
--           "reps": "8-10",
--           "rest_seconds": 90,
--           "notes": "Focus on form"
--         }
--       ]
--     }
--   ],
--   "nutrition_guidelines": {
--     "daily_calories": 2500,
--     "protein_grams": 150,
--     "notes": "High protein for muscle growth"
--   }
-- }

-- =====================================================
-- TRIGGERS & FUNCTIONS
-- Auto-update updated_at timestamp on row updates
-- =====================================================

-- Create the trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to users table
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to workouts table
CREATE TRIGGER update_workouts_updated_at
  BEFORE UPDATE ON workouts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to meals table
CREATE TRIGGER update_meals_updated_at
  BEFORE UPDATE ON meals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to health_metrics table
CREATE TRIGGER update_health_metrics_updated_at
  BEFORE UPDATE ON health_metrics
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to goal_calendars table
CREATE TRIGGER update_goal_calendars_updated_at
  BEFORE UPDATE ON goal_calendars
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to workout_plans table
CREATE TRIGGER update_workout_plans_updated_at
  BEFORE UPDATE ON workout_plans
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VERIFICATION QUERIES
-- Run these after schema creation to verify setup
-- =====================================================

-- List all tables
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Count indexes per table
-- SELECT
--   tablename,
--   COUNT(*) as index_count
-- FROM pg_indexes
-- WHERE schemaname = 'public'
-- GROUP BY tablename;

-- Verify foreign key constraints
-- SELECT
--   tc.table_name,
--   kcu.column_name,
--   ccu.table_name AS foreign_table_name,
--   ccu.column_name AS foreign_column_name
-- FROM information_schema.table_constraints AS tc
-- JOIN information_schema.key_column_usage AS kcu
--   ON tc.constraint_name = kcu.constraint_name
-- JOIN information_schema.constraint_column_usage AS ccu
--   ON ccu.constraint_name = tc.constraint_name
-- WHERE tc.constraint_type = 'FOREIGN KEY';

-- =====================================================
-- SCHEMA CREATION COMPLETE
-- =====================================================
-- Next steps:
-- 1. Run this script in your Supabase SQL Editor
-- 2. Verify all tables are created
-- 3. Update your .env file with Supabase credentials
-- 4. Configure TypeORM to connect to Supabase with SSL
-- =====================================================
