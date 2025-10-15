# Railway Deployment Guide

## 🚀 Quick Start Deployment

### Prerequisites
- ✅ Railway Pro account ($20/month) - **DONE**
- ✅ GitHub repository with backend code
- ✅ Backend tested locally and working

---

## 📋 Step-by-Step Deployment Process

### **Step 1: Install Railway CLI** (Optional but recommended)

```bash
# Install Railway CLI globally
npm install -g @railway/cli

# Login to Railway
railway login
```

*Note: You can also deploy via Railway web dashboard without CLI*

---

### **Step 2: Create New Railway Project**

#### Option A: Via Railway Dashboard (Easier for first time)

1. Go to [railway.app/dashboard](https://railway.app/dashboard)
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Authorize Railway to access your GitHub
5. Select repository: `PlainMyth/AdaptFitness`
6. Select directory: `adaptfitness-backend`
7. Click **"Deploy Now"**

#### Option B: Via Railway CLI

```bash
# Navigate to backend directory
cd /Users/csuftitan/Downloads/AdaptFitness/AdaptFitness/adaptfitness-backend

# Initialize Railway project
railway init

# Link to existing project (if you already created one)
railway link
```

---

### **Step 3: Add PostgreSQL Database**

#### Via Railway Dashboard:

1. In your Railway project dashboard
2. Click **"+ New"** → **"Database"** → **"Add PostgreSQL"**
3. Railway auto-configures connection
4. Database URL is automatically added to environment variables as `DATABASE_URL`

#### Via Railway CLI:

```bash
# Add PostgreSQL to project
railway add --database postgresql
```

**Railway will automatically set these environment variables:**
- `DATABASE_URL` - Full connection string
- `PGHOST` - Database host
- `PGPORT` - Database port (5432)
- `PGUSER` - Database username
- `PGPASSWORD` - Database password
- `PGDATABASE` - Database name

---

### **Step 4: Configure Environment Variables**

You need to set these **manually** in Railway dashboard:

#### Required Environment Variables:

```bash
# JWT Configuration
JWT_SECRET=<your-128-char-secret-from-.env>
JWT_EXPIRES_IN=24h

# Database Configuration (if not using DATABASE_URL)
DATABASE_HOST=${PGHOST}
DATABASE_PORT=${PGPORT}
DATABASE_USERNAME=${PGUSER}
DATABASE_PASSWORD=${PGPASSWORD}
DATABASE_NAME=${PGDATABASE}

# Application Configuration
NODE_ENV=production
PORT=3000

# CORS Configuration (update with your iOS app domain or use * for development)
CORS_ORIGIN=*
```

#### How to Set Environment Variables:

**Via Dashboard:**
1. Go to your Railway project
2. Click on your service (backend)
3. Click **"Variables"** tab
4. Click **"+ New Variable"**
5. Add each variable (key-value pairs)
6. Click **"Deploy"** to apply changes

**Via CLI:**
```bash
# Set individual variable
railway variables set JWT_SECRET="your-secret-here"

# Set from .env file (be careful - only use for non-sensitive or development)
# railway variables set --from .env
```

---

### **Step 5: Deploy Backend**

#### Via Dashboard:
- Railway auto-deploys on every GitHub push to main branch
- Or click **"Deploy"** button manually

#### Via CLI:
```bash
# Deploy current code
railway up

# Or deploy specific branch
railway up --branch main
```

---

### **Step 6: Monitor Deployment**

#### Check Build Logs:

**Via Dashboard:**
1. Go to your service
2. Click **"Deployments"** tab
3. Click on latest deployment
4. View build and runtime logs

**Via CLI:**
```bash
# View logs
railway logs

# Follow logs in real-time
railway logs --follow
```

#### What to look for:
```
✅ Building application...
✅ Installing dependencies...
✅ Running npm run build...
✅ TypeScript compilation successful
✅ Starting application: npm run start:prod
✅ NestJS application successfully started
✅ Application is listening on port 3000
```

---

### **Step 7: Get Your Production URL**

#### Via Dashboard:
1. Go to your service
2. Click **"Settings"** tab
3. Scroll to **"Domains"**
4. Copy the auto-generated URL: `https://adaptfitness-production.up.railway.app`

#### Via CLI:
```bash
# Get service URL
railway status

# Or open in browser
railway open
```

---

### **Step 8: Test Production API**

```bash
# Test health endpoint
curl https://your-app.railway.app/health

# Expected response:
{
  "status": "ok",
  "timestamp": "2024-10-15T...",
  "uptime": 12345,
  "database": "connected"
}

# Test registration
curl -X POST https://your-app.railway.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@railway.com",
    "password": "RailwayTest123!",
    "firstName": "Railway",
    "lastName": "Test"
  }'

# Expected response:
{
  "message": "User registered successfully",
  "user": { ... }
}
```

---

## 🔧 Railway Configuration Files Explained

### **Procfile**
Tells Railway how to start your application:
```
web: npm run start:prod
```

### **railway.json**
Railway-specific configuration:
```json
{
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "npm install && npm run build"
  },
  "deploy": {
    "numReplicas": 1,
    "sleepApplication": false,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10,
    "startCommand": "npm run start:prod"
  }
}
```

### **.railwayignore**
Excludes unnecessary files from deployment (like .gitignore):
- Test files
- Development configs
- Documentation (except README)

---

## 👥 Team Collaboration Setup

### **Add Team Members:**

1. Go to Railway project settings
2. Click **"Members"** tab
3. Click **"Invite Member"**
4. Enter teammate email addresses
5. Set permission level:
   - **Admin** - Full access (recommended for all 3 team members)
   - **Member** - Deploy and view only

### **What Team Members Can Do:**
- ✅ View deployments and logs
- ✅ Trigger new deployments
- ✅ Manage environment variables
- ✅ View database
- ✅ Monitor application metrics

### **Team Workflow:**
1. Any team member pushes to GitHub main branch
2. Railway auto-deploys the new code
3. All team members see deployment status in dashboard
4. All can debug using shared logs

---

## 🎯 Custom Domain Setup (Optional)

### **Add Custom Domain:**

1. Purchase domain (e.g., `adaptfitness.com`)
2. Go to Railway project → Settings → Domains
3. Click **"Custom Domain"**
4. Enter your domain: `api.adaptfitness.com`
5. Railway provides CNAME record
6. Add CNAME to your DNS provider:
   ```
   Type: CNAME
   Name: api
   Value: your-app.railway.app
   TTL: 3600
   ```
7. Wait for DNS propagation (5-30 minutes)
8. Railway auto-provisions SSL certificate

---

## 📊 Monitoring & Maintenance

### **Monitor Application Health:**

**Via Dashboard:**
- View real-time metrics (CPU, Memory, Network)
- Check deployment history
- Monitor database usage
- Set up notifications for failures

**Via CLI:**
```bash
# Check service status
railway status

# View metrics
railway metrics

# View recent logs
railway logs --limit 100
```

### **Database Backups:**
- Railway Pro includes automatic daily backups
- View backups in Database → Backups tab
- Restore from any backup point

### **Scaling (If needed):**
```bash
# Scale replicas via dashboard:
Settings → Replicas → Increase/Decrease

# Railway Pro supports:
- Horizontal scaling (multiple instances)
- Vertical scaling (more CPU/RAM)
```

---

## 🐛 Troubleshooting

### **Issue: Build Fails**

**Check:**
1. Verify `package.json` has all dependencies
2. Check build logs for TypeScript errors
3. Ensure `engines` field specifies Node.js version
4. Verify `build` script exists and works locally

**Fix:**
```bash
# Test build locally first
npm run build

# Check for TypeScript errors
npm run lint
```

### **Issue: Application Crashes on Start**

**Check:**
1. Environment variables are set correctly
2. Database connection successful
3. PORT is not hardcoded (use `process.env.PORT`)
4. All required env vars exist (JWT_SECRET, DATABASE_URL)

**Fix:**
```bash
# View crash logs
railway logs --filter error

# Verify environment variables
railway variables
```

### **Issue: Database Connection Failed**

**Check:**
1. PostgreSQL service is running
2. DATABASE_URL is set automatically by Railway
3. TypeORM configuration uses environment variables

**Fix:**
```bash
# Check database status
railway run -- psql -c "\l"

# Test connection
railway run -- npm run start:prod
```

### **Issue: 502 Bad Gateway**

**Possible causes:**
1. Application not listening on correct PORT
2. Application crashed during startup
3. Build successful but start command failed

**Fix:**
```bash
# Ensure main.ts uses process.env.PORT
const port = process.env.PORT || 3000;
await app.listen(port);

# Check start command
railway logs --deployment latest
```

---

## ✅ Deployment Checklist

Before deploying:
- [ ] All tests passing locally (`npm test`)
- [ ] Application builds successfully (`npm run build`)
- [ ] Environment variables documented
- [ ] `.env` file NOT committed to Git
- [ ] Procfile created
- [ ] railway.json configured
- [ ] package.json has engines and start:prod script

After deploying:
- [ ] Health endpoint returns 200
- [ ] Can register new user
- [ ] Can login with credentials
- [ ] Can access protected endpoints with JWT
- [ ] Database migrations applied (if any)
- [ ] Team members invited to project
- [ ] Production URL shared with frontend team

---

## 📱 Connect iOS App to Production

Update iOS app to use production URL:

```swift
// adaptfitness-ios/AdaptFitness/Utils/Constants.swift

struct APIConstants {
    #if DEBUG
    static let baseURL = "http://localhost:3000" // Local development
    #else
    static let baseURL = "https://your-app.railway.app" // Production
    #endif
}
```

Or use environment configuration:
```swift
static let baseURL = ProcessInfo.processInfo.environment["API_URL"] 
    ?? "https://your-app.railway.app"
```

---

## 💰 Railway Pro Features (What You're Getting for $20/month)

- ✅ $20 usage credits per month
- ✅ Unlimited projects and services
- ✅ Automatic daily backups
- ✅ Priority support
- ✅ Advanced metrics and monitoring
- ✅ Custom domains with SSL
- ✅ Team collaboration (unlimited members)
- ✅ Increased resource limits
- ✅ Faster builds and deployments

**Your $20/month typically covers:**
- 1 backend service (NestJS)
- 1 PostgreSQL database
- Moderate traffic (good for capstone demos)
- Team of 3 developers

---

## 🎓 For Your Capstone Demo

**Before Demo Day:**
1. ✅ Deploy to Railway (DONE when you follow this guide)
2. ✅ Test all endpoints work in production
3. ✅ Update iOS app with production URL
4. ✅ Create demo user account
5. ✅ Document API URL in README

**During Demo:**
1. Show iOS app working on real iPhone
2. Explain it's connected to Railway cloud backend
3. Demonstrate user registration → login → workout tracking
4. Show Railway dashboard (deployment, logs, monitoring)
5. Highlight security features (JWT, rate limiting, password validation)

**Talking Points:**
- "Backend deployed to Railway cloud platform"
- "PostgreSQL database in production"
- "HTTPS secured with SSL certificates"
- "Team of 3 developers collaborating via Railway"
- "Auto-deploys on GitHub push"
- "Monitoring and logging configured"

---

## 📞 Support

**Railway Documentation:**
- [Railway Docs](https://docs.railway.app)
- [Railway Discord](https://discord.gg/railway)

**If you get stuck:**
1. Check Railway logs: `railway logs`
2. Check Railway status: [status.railway.app](https://status.railway.app)
3. Ask in Railway Discord (very responsive community)
4. Check Railway docs troubleshooting section

---

## 🚀 Next Steps After Deployment

1. **Update Frontend** - Give iOS team the production URL
2. **Test E2E** - Run full authentication flow from iOS app
3. **Monitor** - Watch logs for errors during first day
4. **Optimize** - Add caching, CDN if needed
5. **Scale** - Increase replicas if traffic grows
6. **Backup** - Verify automatic backups are working

**Your backend is now production-ready! 🎉**

