# 🚀 Railway Deployment Checklist

Print this and check off as you go!

## ✅ Pre-Deployment (Already Done!)
- [x] Railway Pro account ($20/month)
- [x] Backend code ready
- [x] All tests passing
- [x] Procfile created
- [x] railway.json created
- [x] Environment variables identified

---

## 📋 Deployment Steps (Do These Now!)

### STEP 1: Create Project (2 min)
- [ ] Go to https://railway.app/dashboard
- [ ] Click "New Project"
- [ ] Select "Deploy from GitHub repo"
- [ ] Choose "PlainMyth/AdaptFitness"
- [ ] Set root directory: `adaptfitness-backend`
- [ ] Click "Deploy Now"

### STEP 2: Add Database (1 min)
- [ ] Click "+ New" button
- [ ] Select "Database" → "PostgreSQL"
- [ ] Wait for provisioning (~30 sec)
- [ ] Verify "Postgres" service shows "Active"

### STEP 3: Set Variables (5 min)
- [ ] Click your backend service
- [ ] Go to "Variables" tab
- [ ] Add these 10 variables:

**DATABASE VARIABLES:**
```
DATABASE_HOST=${{Postgres.PGHOST}}
DATABASE_PORT=${{Postgres.PGPORT}}
DATABASE_USERNAME=${{Postgres.PGUSER}}
DATABASE_PASSWORD=${{Postgres.PGPASSWORD}}
DATABASE_NAME=${{Postgres.PGDATABASE}}
```

**APP VARIABLES:**
```
JWT_SECRET=10d5e69d056caad02185db7fc0711c258cd3306e7c8889394e9101c90ba2013e600de2d56334327571f06869373531df69ca1e4b9288a0de1ab28ef39e514bb3
JWT_EXPIRES_IN=24h
NODE_ENV=production
PORT=3000
CORS_ORIGIN=*
```

- [ ] Click "Deploy" after adding all variables

### STEP 4: Monitor Build (3 min)
- [ ] Go to "Deployments" tab
- [ ] Click latest deployment
- [ ] Watch for these in logs:
  - [ ] "Installing dependencies..."
  - [ ] "Building application..."
  - [ ] "Build successful"
  - [ ] "Application listening on port 3000"

### STEP 5: Get URL (1 min)
- [ ] Go to "Settings" tab
- [ ] Find "Networking" section
- [ ] Copy your Railway URL
- [ ] Write it here: _______________________________

### STEP 6: Test Deployment (2 min)
- [ ] Run: `./test-railway.sh YOUR-URL`
- [ ] Verify health check passes
- [ ] Verify registration works
- [ ] Verify login works

---

## 🎯 Success Criteria

You're done when:
- [ ] Health endpoint returns: `{"status":"ok"}`
- [ ] Can register new user
- [ ] Can login and receive JWT token
- [ ] Database is connected
- [ ] No errors in Railway logs

---

## 📝 Your Production URL

**Railway URL:** _________________________________________

**Use this URL in iOS app:** 
```swift
let baseURL = "https://YOUR-URL-HERE"
```

---

## 🆘 Troubleshooting

**Build Failed?**
- Check: All dependencies in package.json
- Check: Build script exists (`npm run build`)
- View: Deployment logs for error details

**500 Error on Start?**
- Check: All environment variables set
- Check: JWT_SECRET is exactly 128 characters
- Check: Database variables use `${{Postgres.PGHOST}}` format

**Database Connection Failed?**
- Check: PostgreSQL service is running
- Check: Both services in same Railway project
- Check: Database variables correctly reference Postgres

**502 Bad Gateway?**
- Check: Application listening on PORT from env
- Check: Start command is `npm run start:prod`
- View: Runtime logs for crash details

---

## 👥 Team Access (Optional)

After deployment:
- [ ] Go to "Settings" → "Members"
- [ ] Invite teammate 1: _______________
- [ ] Invite teammate 2: _______________
- [ ] Set role: Admin

---

## 🔄 Future Deployments

Once set up, future deploys are automatic:
```bash
git add .
git commit -m "Update feature"
git push origin main
```
Railway auto-detects and deploys in 2-3 minutes!

---

## ✅ Final Verification

- [ ] Backend deployed to Railway
- [ ] Production URL obtained
- [ ] All endpoints tested
- [ ] iOS team has URL
- [ ] Team members invited (optional)
- [ ] Documentation updated

**🎉 YOU'RE LIVE IN PRODUCTION! 🎉**

