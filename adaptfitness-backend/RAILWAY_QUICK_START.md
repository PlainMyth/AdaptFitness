# 🚀 Railway Deployment - Quick Start Guide

## ✅ Pre-Deployment Checklist (COMPLETED)

- ✅ Railway Pro account activated ($20/month)
- ✅ package.json configured with engines and start:prod
- ✅ Procfile created
- ✅ railway.json configured
- ✅ .railwayignore created
- ✅ Build tested successfully
- ✅ All dependencies added

**Your backend is ready to deploy! 🎉**

---

## 🎯 Deployment Steps (15 minutes)

### **Step 1: Go to Railway Dashboard** (2 min)

1. Open browser: [railway.app/dashboard](https://railway.app/dashboard)
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**

### **Step 2: Connect GitHub Repository** (3 min)

1. Click **"Configure GitHub App"** (if first time)
2. Authorize Railway to access your repositories
3. Select repository: **`PlainMyth/AdaptFitness`**
4. Select the root path or specify: **`adaptfitness-backend`**
5. Click **"Deploy Now"**

Railway will:
- ✅ Clone your repository
- ✅ Detect it's a Node.js app
- ✅ Run `npm install && npm run build`
- ✅ Start with `npm run start:prod`

### **Step 3: Add PostgreSQL Database** (2 min)

1. In your Railway project dashboard
2. Click **"+ New"** button
3. Select **"Database"**
4. Choose **"Add PostgreSQL"**
5. Wait for database to provision (~30 seconds)

**Railway automatically creates these variables:**
- `DATABASE_URL` - Full PostgreSQL connection string
- `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`

### **Step 4: Set Environment Variables** (5 min)

**CRITICAL: You must set these manually!**

1. Click on your **backend service** (not the database)
2. Go to **"Variables"** tab
3. Click **"+ New Variable"** for each:

```bash
# Copy these EXACTLY as shown:

JWT_SECRET=10d5e69d056caad02185db7fc0711c258cd3306e7c8889394e9101c90ba2013e600de2d56334327571f06869373531df69ca1e4b9288a0de1ab28ef39e514bb3

JWT_EXPIRES_IN=24h

NODE_ENV=production

PORT=3000

CORS_ORIGIN=*

# Database vars (Railway sets these automatically from PostgreSQL service)
DATABASE_HOST=${{Postgres.PGHOST}}
DATABASE_PORT=${{Postgres.PGPORT}}
DATABASE_USERNAME=${{Postgres.PGUSER}}
DATABASE_PASSWORD=${{Postgres.PGPASSWORD}}
DATABASE_NAME=${{Postgres.PGDATABASE}}
```

**How to reference PostgreSQL variables:**
- Railway uses `${{ServiceName.VARIABLE}}` syntax
- Your PostgreSQL service is usually named "Postgres"
- This links backend to database automatically

4. Click **"Deploy"** to apply changes

### **Step 5: Monitor Deployment** (3 min)

1. Go to **"Deployments"** tab
2. Click on the latest deployment
3. Watch the logs for:

```
✅ Installing dependencies...
✅ Building application...
✅ Build successful
✅ Starting application...
✅ Nest application successfully started
✅ Application listening on port 3000
```

**If you see errors:**
- Check environment variables are set correctly
- Ensure JWT_SECRET is exactly 128 characters
- Verify database connection variables

### **Step 6: Get Your Production URL** (1 min)

1. Click on your backend service
2. Go to **"Settings"** tab
3. Scroll to **"Networking"** section
4. Find **"Public Networking"**
5. Copy the URL (looks like): 
   ```
   https://adaptfitness-production.up.railway.app
   ```
6. Or click **"Generate Domain"** if not auto-generated

---

## 🧪 Test Your Deployment

### **Test 1: Health Check**

```bash
curl https://YOUR-APP.railway.app/health
```

**Expected response:**
```json
{
  "status": "ok",
  "timestamp": "2024-10-15T...",
  "uptime": 123,
  "database": "connected"
}
```

### **Test 2: Register User**

```bash
curl -X POST https://YOUR-APP.railway.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "railway@test.com",
    "password": "Railway123!",
    "firstName": "Railway",
    "lastName": "Test"
  }'
```

**Expected response:**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": "...",
    "email": "railway@test.com",
    "firstName": "Railway",
    "lastName": "Test"
  }
}
```

### **Test 3: Login**

```bash
curl -X POST https://YOUR-APP.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "railway@test.com",
    "password": "Railway123!"
  }'
```

**Expected response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

---

## 👥 Add Team Members (Optional - 2 min)

1. Go to project **"Settings"**
2. Click **"Members"** tab
3. Click **"Invite Member"**
4. Enter email addresses:
   - Teammate 1: `their-email@example.com`
   - Teammate 2: `their-email@example.com`
5. Set role: **Admin** (gives full access)
6. Send invites

**Team members can now:**
- View deployments and logs
- Trigger new deployments
- Manage environment variables
- Monitor metrics

---

## 📱 Update iOS App

Once deployed, update your iOS app to use the production URL:

**File: `adaptfitness-ios/AdaptFitness/Core/Network/APIService.swift`**

```swift
// Change from:
private let baseURL = "http://localhost:3000"

// To:
private let baseURL = "https://your-app.railway.app"
```

**Or use environment-based configuration:**

```swift
#if DEBUG
    private let baseURL = "http://localhost:3000"
#else
    private let baseURL = "https://your-app.railway.app"
#endif
```

---

## 🔄 Auto-Deploy on Git Push

Railway automatically deploys when you push to GitHub:

```bash
# Make changes to backend
cd adaptfitness-backend

# Commit and push
git add .
git commit -m "Update API"
git push origin main

# Railway auto-detects push and deploys
# Watch deployment in Railway dashboard
```

**No manual deployment needed!** Railway watches your GitHub repo.

---

## 🐛 Common Issues & Fixes

### Issue: "Application failed to start"

**Solution:**
1. Check environment variables (especially JWT_SECRET)
2. Verify database connection variables
3. View logs: Deployments → Latest → Logs
4. Ensure PORT is set to 3000

### Issue: "Database connection failed"

**Solution:**
1. Verify PostgreSQL service is running
2. Check database variables reference: `${{Postgres.PGHOST}}`
3. Ensure both services are in same project
4. Test connection in Railway terminal: `railway run psql`

### Issue: "502 Bad Gateway"

**Solution:**
1. Application likely crashed on start
2. Check logs for errors
3. Verify start command: `npm run start:prod`
4. Ensure `dist/main.js` exists after build

### Issue: "Environment variable not found"

**Solution:**
1. Click Variables tab
2. Verify all required vars are set
3. Click "Deploy" to apply changes
4. Wait for new deployment to complete

---

## 📊 Monitor Your Application

### **View Metrics:**
1. Go to your service
2. Click **"Metrics"** tab
3. See:
   - CPU usage
   - Memory usage
   - Network traffic
   - Request latency

### **View Logs:**
1. Go to **"Deployments"**
2. Click latest deployment
3. View real-time logs
4. Filter by error/warning/info

### **Database Access:**
1. Click on PostgreSQL service
2. Click **"Data"** tab to view tables
3. Or click **"Connect"** for connection details
4. Use any PostgreSQL client (TablePlus, pgAdmin)

---

## ✅ Deployment Success Checklist

After deployment, verify:

- [ ] Health endpoint returns 200 OK
- [ ] Can register new user via API
- [ ] Can login and receive JWT token
- [ ] Can access protected endpoint with token
- [ ] Database is connected and persisting data
- [ ] Environment variables all set correctly
- [ ] Team members have been invited (if applicable)
- [ ] Production URL shared with frontend team
- [ ] iOS app updated with production URL
- [ ] Tested full auth flow from iOS app

---

## 🎓 For Your Capstone Demo

**What to Show:**
1. ✅ iOS app working on real iPhone
2. ✅ Backend deployed to Railway (show dashboard)
3. ✅ PostgreSQL database in cloud
4. ✅ HTTPS secured API
5. ✅ Team collaboration features
6. ✅ Auto-deployment from GitHub
7. ✅ Monitoring and logging

**Talking Points:**
- "Full-stack application deployed to production cloud infrastructure"
- "Backend API on Railway, auto-deploys on Git push"
- "PostgreSQL database with automatic backups"
- "HTTPS secured with SSL certificates"
- "Team of 3 developers collaborating in real-time"
- "Professional monitoring and error tracking"

---

## 📞 Need Help?

**Railway Support:**
- [Railway Docs](https://docs.railway.app)
- [Railway Discord](https://discord.gg/railway) - Very responsive!
- [Railway Status](https://status.railway.app)

**Your Deployment Guide:**
- Full details: `DEPLOYMENT.md`
- This quick start: `RAILWAY_QUICK_START.md`

---

## 🚀 You're Ready!

Your backend is **production-ready** and **configured for Railway**.

**Next steps:**
1. Follow Step 1-6 above (15 minutes total)
2. Test with curl commands
3. Share production URL with iOS team
4. Make your first deployment! 🎉

**Railway URL Format:**
```
https://adaptfitness-production-[random].up.railway.app
```

Good luck! Your capstone MVP is about to go live! 🚀

