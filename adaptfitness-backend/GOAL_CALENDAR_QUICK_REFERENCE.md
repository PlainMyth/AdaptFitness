# Goal Calendar Quick Reference

## 🎯 Goal Types

| Type | Description | Unit | Example |
|------|-------------|------|---------|
| `workouts_count` | Number of workouts | workouts | 5 workouts/week |
| `total_duration` | Exercise time | minutes | 300 minutes/week |
| `total_calories` | Calories burned | calories | 1500 calories/week |
| `total_sets` | Sets performed | sets | 50 sets/week |
| `total_reps` | Repetitions | reps | 500 reps/week |
| `total_weight` | Weight lifted | kg | 5000 kg/week |
| `streak_days` | Consecutive days | days | 7 days streak |

## 📅 API Endpoints

### Basic CRUD
```bash
# Create goal
POST /goal-calendar

# Get all goals
GET /goal-calendar

# Get current week goals
GET /goal-calendar/current-week

# Get specific goal
GET /goal-calendar/:id

# Update goal
PATCH /goal-calendar/:id

# Delete goal
DELETE /goal-calendar/:id
```

### Progress & Analytics
```bash
# Update single goal progress
POST /goal-calendar/:id/update-progress

# Update all goals progress
POST /goal-calendar/update-all-progress

# Get goal statistics
GET /goal-calendar/statistics

# Get calendar view
GET /goal-calendar/calendar-view?year=2024&month=1
```

## 🏋️‍♀️ Workout Types

| Type | Description |
|------|-------------|
| `strength` | Weight training, resistance |
| `cardio` | Running, cycling, swimming |
| `flexibility` | Yoga, stretching |
| `sports` | Team sports, tennis |
| `other` | Other activities |

## 📊 Goal Status Levels

| Status | Completion % | Description |
|--------|--------------|-------------|
| `not_started` | 0% | No progress yet |
| `started` | 1-49% | Some progress made |
| `moderate_progress` | 50-74% | Halfway there |
| `on_track` | 75-99% | Almost complete |
| `achieved` | 100%+ | Goal exceeded |
| `completed` | 100%+ | Goal marked complete |

## 🔧 Quick Setup Examples

### 1. Weekly Workout Goal
```json
{
  "weekStartDate": "2024-01-15",
  "weekEndDate": "2024-01-21",
  "goalType": "workouts_count",
  "targetValue": 5,
  "description": "Complete 5 workouts this week",
  "isActive": true
}
```

### 2. Calorie Burning Goal
```json
{
  "weekStartDate": "2024-01-15",
  "weekEndDate": "2024-01-21",
  "goalType": "total_calories",
  "targetValue": 1500,
  "description": "Burn 1500 calories",
  "isActive": true
}
```

### 3. Strength Training Goal
```json
{
  "weekStartDate": "2024-01-15",
  "weekEndDate": "2024-01-21",
  "goalType": "workouts_count",
  "targetValue": 3,
  "description": "3 strength sessions",
  "workoutType": "strength",
  "isActive": true
}
```

### 4. Exercise Duration Goal
```json
{
  "weekStartDate": "2024-01-15",
  "weekEndDate": "2024-01-21",
  "goalType": "total_duration",
  "targetValue": 300,
  "description": "300 minutes of exercise",
  "isActive": true
}
```

## 📈 Progress Tracking Flow

1. **Set Goals**: Create weekly goals via API
2. **Log Workouts**: Use existing workout endpoints
3. **Update Progress**: Call progress update endpoints
4. **Monitor Results**: Check completion percentages
5. **Adjust Goals**: Modify targets as needed

## 🗓️ Week Date Calculation

Goals are tracked Monday to Sunday:
- **Week Start**: Monday 00:00:00
- **Week End**: Sunday 23:59:59
- **Current Week**: Automatically calculated from today's date

## 📋 Testing Commands

```bash
# Run comprehensive test
./test-goal-calendar.sh

# Test specific endpoints
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/goal-calendar/current-week

curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/goal-calendar/statistics
```

## 🔄 Integration Points

- **Workout Module**: Automatically calculates progress from workout data
- **User Module**: Links goals to specific users
- **Health Metrics**: Can be extended to track body composition goals
- **Authentication**: All endpoints require JWT authentication

## 💡 Tips

- Update progress after each workout session
- Use specific workout types for targeted goals
- Set realistic weekly targets
- Monitor statistics for long-term trends
- Use calendar view for monthly planning
