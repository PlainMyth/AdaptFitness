# Railway Variables - Quick Setup

## 🎯 Copy These 11 Variables to Railway Dashboard

### **Where to Add:**
Railway Dashboard → Your Backend Service → Variables Tab → Add Variable

---

## 📋 Variables to Add

### **From Railway PostgreSQL Service** (5 variables)

Click on your PostgreSQL service → Variables tab → Copy these values:

```
DATABASE_HOST        = [Copy from PGHOST]
DATABASE_PORT        = [Copy from PGPORT]  
DATABASE_USERNAME    = [Copy from PGUSER]
DATABASE_PASSWORD    = [Copy from PGPASSWORD]
DATABASE_NAME        = [Copy from PGDATABASE]
```

### **From Your Local .env File** (2 variables)

```
JWT_SECRET           = [Copy your 128-char hex secret from local .env]
JWT_EXPIRES_IN       = 15m
```

### **Application Settings** (3 variables)

```
NODE_ENV             = production
PORT                 = 3000
CORS_ORIGIN          = *
```

### **⚠️ CRITICAL - Initial Deployment Only** (1 variable)

```
TYPEORM_SYNCHRONIZE  = true
```

**IMPORTANT**: After your first successful deployment and tables are created, change this to `false`.

---

## 🚀 Quick Steps

1. **Add all 11 variables** in Railway dashboard
2. **Save** → Railway auto-redeploys (~3-5 min)
3. **Check deploy logs** → Look for "Nest application successfully started"
4. **Verify tables created** → Test registration endpoint
5. **Lock down**: Change `TYPEORM_SYNCHRONIZE` to `false`
6. **Redeploy** → Production-ready! 🎉

---

## ✅ Verification

After deployment, test with:

```bash
# Test from your local terminal
./test-railway.sh https://adaptfitness-production.up.railway.app
```

Expected results:
- ✅ Health check: HTTP 200
- ✅ Registration: HTTP 201
- ✅ Login: HTTP 200
- ✅ Protected endpoint: HTTP 401 (without token)

---

## 🔒 Production Lock-Down Checklist

After successful first deployment:

- [ ] Verify all endpoints work
- [ ] Check database tables exist (`users`, `workouts`, `meals`, `health_metrics`)
- [ ] Change `TYPEORM_SYNCHRONIZE` from `true` to `false`
- [ ] Redeploy
- [ ] Verify app still works
- [ ] Your backend is production-ready! 🎉

---

**Total Setup Time**: 5-10 minutes  
**Deployment Time**: 3-5 minutes per deploy

