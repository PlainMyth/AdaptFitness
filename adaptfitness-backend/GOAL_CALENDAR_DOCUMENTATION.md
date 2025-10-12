# Goal Calendar System Documentation

## Overview

The Goal Calendar system is a comprehensive fitness goal tracking feature that allows users to set weekly fitness goals and track their progress against actual workout data. It provides calendar-based visualization, progress tracking, and integration with the existing workout module.

## Key Features

### 🎯 Goal Types
- **Workouts Count**: Track number of workouts completed
- **Total Duration**: Track total exercise time in minutes
- **Total Calories**: Track total calories burned
- **Total Sets**: Track total sets performed
- **Total Reps**: Track total repetitions completed
- **Total Weight**: Track total weight lifted
- **Streak Days**: Track consecutive workout days

### 📅 Calendar Integration
- Weekly goal tracking (Monday to Sunday)
- Monthly calendar view
- Progress visualization
- Goal completion tracking

### 📊 Progress Tracking
- Real-time progress calculation based on workout data
- Automatic goal completion detection
- Progress history tracking (last 30 days)
- Goal statistics and analytics

## Database Schema

### GoalCalendar Entity

```typescript
@Entity('goal_calendars')
export class GoalCalendar {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @Column({ type: 'date' })
  weekStartDate: Date;

  @Column({ type: 'date' })
  weekEndDate: Date;

  @Column({
    type: 'enum',
    enum: ['workouts_count', 'total_duration', 'total_calories', 'total_sets', 'total_reps', 'total_weight', 'streak_days']
  })
  goalType: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  targetValue: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  currentValue: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  completionPercentage: number;

  @Column({ default: false })
  isCompleted: boolean;

  @Column({ default: false })
  isActive: boolean;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ 
    nullable: true,
    type: 'enum',
    enum: ['strength', 'cardio', 'flexibility', 'sports', 'other']
  })
  workoutType: string;

  @Column({ type: 'json', nullable: true })
  progressHistory: any[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

## API Endpoints

### Goal Management

#### Create Goal
```http
POST /goal-calendar
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "weekStartDate": "2024-01-15",
  "weekEndDate": "2024-01-21",
  "goalType": "workouts_count",
  "targetValue": 5,
  "description": "Complete 5 workouts this week",
  "workoutType": "strength",
  "isActive": true
}
```

#### Get All Goals
```http
GET /goal-calendar
Authorization: Bearer <jwt_token>
```

#### Get Current Week Goals
```http
GET /goal-calendar/current-week
Authorization: Bearer <jwt_token>
```

#### Get Goal by ID
```http
GET /goal-calendar/:id
Authorization: Bearer <jwt_token>
```

#### Update Goal
```http
PATCH /goal-calendar/:id
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "targetValue": 6,
  "description": "Updated goal description"
}
```

#### Delete Goal
```http
DELETE /goal-calendar/:id
Authorization: Bearer <jwt_token>
```

### Progress Tracking

#### Update Single Goal Progress
```http
POST /goal-calendar/:id/update-progress
Authorization: Bearer <jwt_token>
```

#### Update All Goals Progress
```http
POST /goal-calendar/update-all-progress
Authorization: Bearer <jwt_token>
```

### Analytics & Visualization

#### Get Goal Statistics
```http
GET /goal-calendar/statistics
Authorization: Bearer <jwt_token>
```

Response:
```json
{
  "totalGoals": 10,
  "completedGoals": 7,
  "activeGoals": 3,
  "completionRate": 70.0,
  "averageCompletion": 85.5,
  "goalTypeStats": {
    "workouts_count": {
      "total": 5,
      "completed": 4,
      "averageCompletion": 90.0
    },
    "total_calories": {
      "total": 3,
      "completed": 2,
      "averageCompletion": 75.0
    }
  }
}
```

#### Get Calendar View
```http
GET /goal-calendar/calendar-view?year=2024&month=1
Authorization: Bearer <jwt_token>
```

## Usage Examples

### Setting Up Weekly Goals

1. **Create a workout frequency goal**:
```javascript
const goal = await fetch('/goal-calendar', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    weekStartDate: '2024-01-15',
    weekEndDate: '2024-01-21',
    goalType: 'workouts_count',
    targetValue: 5,
    description: 'Complete 5 workouts this week',
    isActive: true
  })
});
```

2. **Create a calorie burning goal**:
```javascript
const calorieGoal = await fetch('/goal-calendar', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    weekStartDate: '2024-01-15',
    weekEndDate: '2024-01-21',
    goalType: 'total_calories',
    targetValue: 1500,
    description: 'Burn 1500 calories this week',
    isActive: true
  })
});
```

3. **Create a strength-specific goal**:
```javascript
const strengthGoal = await fetch('/goal-calendar', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    weekStartDate: '2024-01-15',
    weekEndDate: '2024-01-21',
    goalType: 'workouts_count',
    targetValue: 3,
    description: 'Complete 3 strength training sessions',
    workoutType: 'strength',
    isActive: true
  })
});
```

### Tracking Progress

The system automatically calculates progress based on workout data. After logging workouts, update goal progress:

```javascript
// Update all goals after logging a workout
await fetch('/goal-calendar/update-all-progress', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

// Or update a specific goal
await fetch(`/goal-calendar/${goalId}/update-progress`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

### Viewing Progress

```javascript
// Get current week goals with progress
const currentGoals = await fetch('/goal-calendar/current-week', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

// Get goal statistics
const stats = await fetch('/goal-calendar/statistics', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

// Get calendar view
const calendar = await fetch('/goal-calendar/calendar-view?year=2024&month=1', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

## Integration with Workout Module

The Goal Calendar system integrates seamlessly with the existing Workout module:

### Automatic Progress Calculation

When workouts are logged, the system automatically:
1. Identifies relevant goals based on date range
2. Calculates progress based on goal type
3. Updates completion percentages
4. Marks goals as completed when targets are met

### Goal Type Calculations

- **workouts_count**: Counts total workouts in the week
- **total_duration**: Sums up total exercise duration in minutes
- **total_calories**: Sums up total calories burned
- **total_sets**: Sums up total sets performed
- **total_reps**: Sums up total repetitions
- **total_weight**: Sums up total weight lifted
- **streak_days**: Calculates consecutive workout days

### Workout Type Filtering

Goals can be filtered by workout type:
- `strength`: Only counts strength training workouts
- `cardio`: Only counts cardio workouts
- `flexibility`: Only counts flexibility/yoga workouts
- `sports`: Only counts sports activities
- `other`: Only counts other workout types
- `null`: Counts all workout types

## Helper Methods

The GoalCalendar entity includes several helper methods:

### Status Calculation
```typescript
get status(): string {
  if (this.isCompleted) return 'completed';
  if (this.completionPercentage >= 100) return 'achieved';
  if (this.completionPercentage >= 75) return 'on_track';
  if (this.completionPercentage >= 50) return 'moderate_progress';
  if (this.completionPercentage > 0) return 'started';
  return 'not_started';
}
```

### Days Remaining
```typescript
get daysRemaining(): number {
  const today = new Date();
  const endDate = new Date(this.weekEndDate);
  endDate.setHours(23, 59, 59, 999);
  
  if (today > endDate) return 0;
  
  const diffTime = endDate.getTime() - today.getTime();
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
}
```

### Unit Display
```typescript
get unit(): string {
  switch (this.goalType) {
    case 'workouts_count': return 'workouts';
    case 'total_duration': return 'minutes';
    case 'total_calories': return 'calories';
    case 'total_sets': return 'sets';
    case 'total_reps': return 'reps';
    case 'total_weight': return 'kg';
    case 'streak_days': return 'days';
    default: return 'units';
  }
}
```

## Testing

Run the comprehensive test script to verify functionality:

```bash
./test-goal-calendar.sh
```

This script will:
1. Create sample goals for the current week
2. Create sample workouts
3. Demonstrate progress tracking
4. Show statistics and calendar views

## Best Practices

### Goal Setting
1. Set realistic, achievable targets
2. Use specific workout types when appropriate
3. Provide clear descriptions for motivation
4. Review and adjust goals weekly

### Progress Tracking
1. Update goals after logging workouts
2. Monitor completion percentages regularly
3. Use statistics to identify patterns
4. Celebrate completed goals

### Calendar Usage
1. Use calendar view for monthly planning
2. Track progress trends over time
3. Identify busy/light weeks
4. Plan goal adjustments based on schedule

## Future Enhancements

Potential future improvements:
1. **Goal Templates**: Pre-defined goal templates for common objectives
2. **Smart Recommendations**: AI-suggested goals based on workout history
3. **Goal Challenges**: Multi-week or monthly challenges
4. **Social Features**: Share goals and progress with friends
5. **Notifications**: Reminders for goal deadlines
6. **Analytics Dashboard**: Advanced progress visualization
7. **Goal Categories**: Organize goals by fitness area (strength, cardio, etc.)
8. **Progress Photos**: Visual progress tracking integration
