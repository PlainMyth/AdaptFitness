# Operations - Health Metrics Feature

**Feature:** Health Metrics Frontend Implementation  
**Sprint:** Sprint 3  
**Status:** In Development

---

## Deployment Documentation

### Feature Overview
The Health Metrics feature adds a new tab to the iOS app that displays health and body composition metrics calculated by the backend API. All calculations are performed server-side for accuracy and consistency.

### New Components Deployed
- **iOS Models:** `HealthMetrics.swift` - Data models for health metrics
- **iOS ViewModels:** `HealthMetricsViewModel.swift` - Business logic and API integration
- **iOS Views:** 
  - `HealthMetricsView.swift` - Main display view
  - `AddHealthMetricsView.swift` - Input form view
- **Navigation:** Updated `MainTabView.swift` to include Health tab

### Backend Endpoints Used
- `GET /health-metrics/latest` - Fetch latest health metrics entry
- `GET /health-metrics/calculations` - Fetch calculated metrics only
- `POST /health-metrics` - Create new health metrics entry
- `GET /health-metrics/:id` - Get specific entry (not used in initial release)
- `PATCH /health-metrics/:id` - Update entry (not used in initial release)
- `DELETE /health-metrics/:id` - Delete entry (not used in initial release)

### Environment Variables
**No new environment variables required** - Uses existing backend configuration.

---

## Monitoring & Logging

### API Endpoint Monitoring

**Endpoints to Monitor:**
1. `GET /health-metrics/latest`
   - Response time target: <200ms
   - Success rate target: >99%
   - Alert if: Response time >500ms, Error rate >1%

2. `GET /health-metrics/calculations`
   - Response time target: <200ms
   - Success rate target: >99%

3. `POST /health-metrics`
   - Response time target: <300ms (includes calculation time)
   - Success rate target: >99%
   - Alert if: Validation errors >5%, Response time >1000ms

### Health Metrics Creation Events
Log the following events:
- Health metrics entry created (userId, entryId, timestamp)
- Health metrics calculation time (ms)
- Any calculation errors or warnings
- Invalid input data attempts

### Error Monitoring
- Track 404 errors (user has no health metrics yet) - not critical
- Track 400 errors (validation failures) - may indicate form issues
- Track 401 errors (authentication failures) - critical
- Track 500 errors (server errors) - critical

---

## Database Operations

### Health Metrics Table
**Table Name:** `health_metrics`

**Schema:**
- Primary key: `id` (integer, auto-increment)
- Foreign key: `userId` (UUID, references users.id)
- Columns: See `health-metrics.entity.ts` for full schema

**Indexes:**
- `userId` - for user queries (already exists)
- `createdAt` - for ordering (already exists)

**No migration required** - Table already exists in production database.

### Data Backup & Restore
- Health metrics included in regular database backups
- Can be restored from PostgreSQL backups
- No special backup procedures needed

### Database Performance
- Estimated row size: ~1KB per entry
- Expected growth: ~1 entry per user per week
- Index performance: Queries are indexed and fast

---

## Performance Monitoring

### API Response Times
**Target Metrics:**
- GET /health-metrics/latest: <200ms (p95)
- GET /health-metrics/calculations: <200ms (p95)
- POST /health-metrics: <300ms (p95)

**Monitoring:**
- Track response times using backend logs
- Alert if p95 exceeds targets
- Monitor calculation time separately (should be <100ms)

### iOS App Performance
**Target Metrics:**
- View load time: <500ms
- Form submission time: <1000ms
- UI responsiveness: <100ms per interaction

**Monitoring:**
- Use Xcode Instruments for performance profiling
- Monitor memory usage (should be <50MB for Health Metrics views)
- Check for UI freezes or lag

---

## Security Considerations

### Data Privacy
- Health metrics are user-specific (isolated by userId)
- JWT authentication required for all endpoints
- No health data exposed without authentication

### Input Validation
- Backend validates all input values
- Weight must be positive and reasonable (0-500 kg)
- Body fat percentage must be 0-100%
- Measurements must be positive

### Data Sensitivity
- Health metrics are sensitive personal data
- Stored securely in PostgreSQL
- Transmitted over HTTPS only
- No logging of sensitive health values in production

---

## Rollback Plan

If issues are discovered in production:

1. **Feature Flag:** Can disable Health tab in iOS app by removing from MainTabView
2. **API Endpoints:** Endpoints are backward-compatible, no breaking changes
3. **Database:** No schema changes, safe to rollback
4. **Client Update:** iOS app can be updated to remove feature if needed

---

## Maintenance

### Regular Tasks
- Monitor API endpoint performance weekly
- Review error logs for calculation issues
- Check database growth and performance
- Update iOS app if backend API changes

### Future Enhancements
- Add history/charts for health metrics over time
- Add export functionality for health data
- Add comparison with previous entries
- Add goal tracking based on health metrics

---

## Support Documentation

### User Support
- Health Metrics FAQ: [To be created]
- Troubleshooting guide: [To be created]
- Known issues: See BUG_TRACKING_HEALTH_METRICS.md

### Developer Support
- API documentation: See backend README.md
- iOS implementation: See code comments
- Testing: See TEST_PLAN_HEALTH_METRICS_FRONTEND.md

---


