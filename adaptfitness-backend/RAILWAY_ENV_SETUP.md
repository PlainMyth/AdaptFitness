# Railway Environment Variables Setup Guide

## Overview
This guide provides the complete list of environment variables required for deploying AdaptFitness backend to Railway.

---

## Required Environment Variables

### 1. Database Configuration

Get these values from your **Railway PostgreSQL service** → Variables tab:

| Variable | Railway Variable | Example Value | Description |
|----------|-----------------|---------------|-------------|
| `DATABASE_HOST` | Copy from `PGHOST` | `postgres.railway.internal` | PostgreSQL host |
| `DATABASE_PORT` | Copy from `PGPORT` | `5432` | PostgreSQL port |
| `DATABASE_USERNAME` | Copy from `PGUSER` | `postgres` | Database username |
| `DATABASE_PASSWORD` | Copy from `PGPASSWORD` | `random_password_here` | Database password |
| `DATABASE_NAME` | Copy from `PGDATABASE` | `railway` | Database name |

### 2. Database Schema Management

| Variable | Value | When to Use |
|----------|-------|-------------|
| `TYPEORM_SYNCHRONIZE` | `true` | **Initial deployment only** - Creates all database tables |
| `TYPEORM_SYNCHRONIZE` | `false` | **After tables created** - Production safety mode |

⚠️ **CRITICAL WORKFLOW**:
1. Set `TYPEORM_SYNCHRONIZE=true` for first deployment
2. Wait for app to start and tables to be created
3. Change to `TYPEORM_SYNCHRONIZE=false` for production safety
4. Redeploy

### 3. JWT Configuration

| Variable | Value | Description |
|----------|-------|-------------|
| `JWT_SECRET` | Copy from your local `.env` | 128-character hex string for signing tokens |
| `JWT_EXPIRES_IN` | `15m` | Access token expiration (15 minutes recommended) |

**To generate a secure JWT secret**:
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

### 4. Application Configuration

| Variable | Value | Description |
|----------|-------|-------------|
| `NODE_ENV` | `production` | Sets application to production mode |
| `PORT` | `3000` | Application port (Railway uses this) |
| `CORS_ORIGIN` | `*` | CORS allowed origins (use `*` for mobile apps) |

---

## Complete Railway Variables Checklist

Copy and paste these into Railway dashboard → Your Backend Service → Variables:

### **Phase 1: Initial Deployment (Creates Tables)**

```bash
# Database (from Railway PostgreSQL service)
DATABASE_HOST=<copy from PGHOST>
DATABASE_PORT=<copy from PGPORT>
DATABASE_USERNAME=<copy from PGUSER>
DATABASE_PASSWORD=<copy from PGPASSWORD>
DATABASE_NAME=<copy from PGDATABASE>

# Schema Management - TEMPORARY
TYPEORM_SYNCHRONIZE=true

# JWT (from your local .env file)
JWT_SECRET=<your 128-char secret>
JWT_EXPIRES_IN=15m

# Application
NODE_ENV=production
PORT=3000
CORS_ORIGIN=*
```

**Total: 11 variables**

### **Phase 2: Production Lock-Down (After Tables Created)**

Once your app starts successfully and tables are created:

1. Go to Railway → Variables
2. **Change** `TYPEORM_SYNCHRONIZE` from `true` to `false`
3. Click "Redeploy"

This ensures schema changes don't happen accidentally in production.

---

## Verification Steps

### Step 1: Check Database Connection
Look at Railway deploy logs for:
```
[InstanceLoader] TypeOrmCoreModule dependencies initialized
```
✅ This means database connected successfully

### Step 2: Check Table Creation
After first deployment with `TYPEORM_SYNCHRONIZE=true`, check PostgreSQL:

```sql
-- In Railway PostgreSQL shell
\dt
```

You should see:
- `users`
- `workouts`
- `meals`
- `health_metrics`

### Step 3: Test API Endpoints
```bash
# Health check
curl https://adaptfitness-production.up.railway.app/health

# Register user
curl -X POST https://adaptfitness-production.up.railway.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!@#","firstName":"Test","lastName":"User"}'

# Login
curl -X POST https://adaptfitness-production.up.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!@#"}'
```

---

## Common Issues & Solutions

### Issue: "relation 'users' does not exist"
**Cause**: `TYPEORM_SYNCHRONIZE` is not set to `true`  
**Fix**: Set `TYPEORM_SYNCHRONIZE=true` and redeploy

### Issue: "Missing required environment variables"
**Cause**: Not all variables are set  
**Fix**: Verify all 11 variables are present in Railway

### Issue: Database connection timeout
**Cause**: Wrong database credentials  
**Fix**: Double-check values from Railway PostgreSQL service

### Issue: JWT secret errors
**Cause**: `JWT_SECRET` not set or too short  
**Fix**: Generate new 128-char secret and add to Railway

---

## Security Best Practices

### ✅ DO:
- Use Railway's built-in PostgreSQL service (automatic backups)
- Generate strong JWT secrets (128+ characters)
- Set `TYPEORM_SYNCHRONIZE=false` after initial deployment
- Use `NODE_ENV=production` for production deployments
- Keep environment variables in Railway (never commit to Git)

### ❌ DON'T:
- Don't leave `TYPEORM_SYNCHRONIZE=true` in production long-term
- Don't use weak JWT secrets
- Don't commit `.env` files to Git
- Don't share database credentials in chat/email

---

## Production Migration Workflow (Future)

Once you have stable tables, migrate to this workflow:

1. **Local Development**: 
   - `TYPEORM_SYNCHRONIZE=true` (auto-sync during development)
   
2. **Production**: 
   - `TYPEORM_SYNCHRONIZE=false` (use migrations)
   - Create migrations: `npm run typeorm migration:generate -- -n MigrationName`
   - Run migrations: `npm run typeorm migration:run`

For now, the `TYPEORM_SYNCHRONIZE` approach is acceptable for MVP deployment.

---

## Quick Reference

**Minimum variables for working deployment**:
1. DATABASE_HOST
2. DATABASE_PORT
3. DATABASE_USERNAME
4. DATABASE_PASSWORD
5. DATABASE_NAME
6. TYPEORM_SYNCHRONIZE (set to `true` initially)
7. JWT_SECRET
8. JWT_EXPIRES_IN
9. NODE_ENV
10. PORT
11. CORS_ORIGIN

**After tables created**, change:
- `TYPEORM_SYNCHRONIZE` → `false`

---

## Next Steps

1. ✅ Set all 11 environment variables in Railway
2. ✅ Wait for automatic redeploy (~3-5 minutes)
3. ✅ Verify tables created in PostgreSQL
4. ✅ Test API endpoints
5. ✅ Change `TYPEORM_SYNCHRONIZE` to `false`
6. ✅ Redeploy for production lock-down

Your backend will then be production-ready! 🚀

