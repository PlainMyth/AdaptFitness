# 🧪 Food API Testing Guide

This guide explains how to test the OpenFoodFacts API integration using the Xcode iOS Simulator.

## 📋 Prerequisites

1. **Backend server running** on `http://localhost:3000`
2. **Xcode project** with the iOS app
3. **Valid JWT authentication token**

---

## 🚀 Quick Start

### Step 1: Start the Backend Server

```bash
cd adaptfitness-backend
npm run start:dev
```

You should see:
```
🚀 AdaptFitness API running on port 3000
📱 Health check: http://localhost:3000/health
```

### Step 2: Test from Terminal (Optional)

Run the test script to verify the API works:

```bash
cd adaptfitness-backend
./test-food-api.sh
```

This will test:
- ✅ Authentication
- ✅ Food search by name
- ✅ Food lookup by barcode

---

## 📱 Testing from iOS Simulator

### Option 1: Using localhost (Recommended)

The iOS Simulator can access `localhost` on your Mac directly.

**In your iOS app:**
- Base URL: `http://localhost:3000`
- Already configured in `APIService.swift`

### Option 2: Using Your Mac's IP Address

If `localhost` doesn't work, use your Mac's local IP:

1. **Find your Mac's IP address:**
   ```bash
   ipconfig getifaddr en0
   # Example output: 192.168.1.100
   ```

2. **Update APIService.swift:**
   ```swift
   private let baseURL = "http://192.168.1.100:3000"
   ```

---

## 🔍 API Endpoints

### 1. Search Foods by Name

**Endpoint:** `GET /meals/foods/search?query=apple&page=1&pageSize=20`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Example Request:**
```swift
let response = try await APIService.shared.searchFoods(
    query: "apple",
    page: 1,
    pageSize: 20,
    token: authToken
)
```

**Example Response:**
```json
{
  "foods": [
    {
      "id": "3017620422003",
      "name": "Apple",
      "brand": "Brand Name",
      "category": "Fruits",
      "imageUrl": "https://...",
      "servingSize": 100,
      "servingUnit": "g",
      "nutritionPer100g": {
        "calories": 52,
        "protein": 0.3,
        "carbs": 14,
        "fat": 0.2,
        "fiber": 2.4,
        "sugar": 10.4,
        "sodium": 1
      },
      "nutritionPerServing": {
        "calories": 52,
        "protein": 0.3,
        "carbs": 14,
        "fat": 0.2
      }
    }
  ],
  "totalCount": 100,
  "page": 1,
  "pageSize": 20,
  "totalPages": 5
}
```

### 2. Get Food by Barcode

**Endpoint:** `GET /meals/foods/barcode/:barcode`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Example Request:**
```swift
let food = try await APIService.shared.getFoodByBarcode(
    barcode: "3017620422003",
    token: authToken
)
```

**Example Response:**
```json
{
  "id": "3017620422003",
  "name": "Nutella",
  "brand": "Ferrero",
  "category": "Spreads",
  "imageUrl": "https://...",
  "servingSize": 15,
  "servingUnit": "g",
  "nutritionPer100g": {
    "calories": 539,
    "protein": 6.3,
    "carbs": 57.5,
    "fat": 30.9,
    "fiber": 0,
    "sugar": 56.3,
    "sodium": 0.007
  },
  "nutritionPerServing": {
    "calories": 81,
    "protein": 0.9,
    "carbs": 8.6,
    "fat": 4.6
  }
}
```

---

## 🧪 Step-by-Step iOS Testing

### 1. Get Authentication Token

First, you need to be logged in. The `AuthManager` handles this automatically.

```swift
// In your view or view model
let authManager = AuthManager.shared
guard let token = authManager.getAccessToken() else {
    // User not logged in
    return
}
```

### 2. Test Food Search

Create a test view or add to an existing view:

```swift
import SwiftUI

struct FoodSearchTestView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var searchQuery = ""
    @State private var searchResults: [SimplifiedFoodItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            TextField("Search for food...", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Search") {
                Task {
                    await searchFoods()
                }
            }
            .disabled(isLoading || searchQuery.isEmpty)
            
            if isLoading {
                ProgressView()
            }
            
            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
            
            List(searchResults) { food in
                VStack(alignment: .leading) {
                    Text(food.name)
                        .font(.headline)
                    if let brand = food.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(Int(food.nutritionPer100g.calories)) kcal per 100g")
                        .font(.caption)
                }
            }
        }
        .padding()
    }
    
    func searchFoods() async {
        guard let token = authManager.getAccessToken() else {
            errorMessage = "Not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.searchFoods(
                query: searchQuery,
                page: 1,
                pageSize: 20,
                token: token
            )
            searchResults = response.foods
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

### 3. Test Barcode Lookup

```swift
func lookupBarcode(_ barcode: String) async {
    guard let token = authManager.getAccessToken() else {
        errorMessage = "Not authenticated"
        return
    }
    
    isLoading = true
    errorMessage = nil
    
    do {
        let food = try await APIService.shared.getFoodByBarcode(
            barcode: barcode,
            token: token
        )
        // Use the food item
        print("Found: \(food.name)")
    } catch {
        errorMessage = error.localizedDescription
    }
    
    isLoading = false
}
```

---

## 🐛 Troubleshooting

### Problem: "Connection refused" or "Cannot connect to server"

**Solutions:**
1. ✅ Make sure backend server is running: `npm run start:dev`
2. ✅ Check server is on port 3000: `curl http://localhost:3000/health`
3. ✅ For iOS Simulator, try using your Mac's IP instead of localhost
4. ✅ Check your Mac's firewall isn't blocking connections

### Problem: "401 Unauthorized"

**Solutions:**
1. ✅ Make sure you're logged in: `AuthManager.shared.isAuthenticated == true`
2. ✅ Check token is valid: `AuthManager.shared.getAccessToken() != nil`
3. ✅ Try logging out and logging back in

### Problem: "No results found" or empty array

**Solutions:**
1. ✅ OpenFoodFacts database may not have that product
2. ✅ Try different search terms
3. ✅ Check the API is working: `./test-food-api.sh`
4. ✅ Some products may not have complete nutrition data

### Problem: "Decoding error" in iOS

**Solutions:**
1. ✅ Check that `FoodSearch.swift` models match backend response
2. ✅ Make sure all required fields are present
3. ✅ Check JSONDecoder date strategy if dates are involved

---

## 📝 Common Test Queries

Here are some good test queries:

- `"apple"` - Should return various apple products
- `"chicken"` - Should return chicken products
- `"bread"` - Should return bread products
- `"3017620422003"` - Nutella barcode (if exists in database)

---

## ✅ Expected Behavior

1. **Search should return results** within 1-2 seconds
2. **Results should have nutrition data** (calories, protein, carbs, fat)
3. **Results should be paginated** (20 items per page by default)
4. **Barcode lookup should return single product** or 404 if not found

---

## 🔗 Additional Resources

- [OpenFoodFacts API Documentation](https://openfoodfacts.github.io/openfoodfacts-server/api/)
- [Backend API Documentation](./CODE_DOCUMENTATION.md)
- [NestJS Documentation](https://docs.nestjs.com/)

---

## 📞 Need Help?

If you encounter issues:
1. Check the backend logs: `npm run start:dev`
2. Check Xcode console for iOS errors
3. Test API directly with `./test-food-api.sh`
4. Verify authentication token is valid

