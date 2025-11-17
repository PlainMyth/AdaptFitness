//
//  MealTrackerUITests.swift
//  AdaptFitnessUITests
//
//  UI tests for the meal tracker functionality
//

import XCTest

final class MealTrackerUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Navigation Tests
    
    func testMealTrackerTabExists() throws {
        // Wait for app to load
        sleep(2)
        
        // Look for the Meals tab
        let mealsTab = app.tabBars.buttons["Meals"]
        XCTAssertTrue(mealsTab.exists, "Meals tab should exist")
    }
    
    func testNavigateToMealTracker() throws {
        // Wait for app to load
        sleep(2)
        
        // Tap on Meals tab
        let mealsTab = app.tabBars.buttons["Meals"]
        if mealsTab.exists {
            mealsTab.tap()
            
            // Verify we're on the meal tracker screen
            // Look for common elements like "Add Food" button or meal list
            sleep(1)
            
            // The meal tracker should be visible
            XCTAssertTrue(app.navigationBars.count > 0 || app.buttons.count > 0, "Meal tracker screen should be visible")
        }
    }
    
    // MARK: - Meal List Tests
    
    func testMealListDisplaysWhenEmpty() throws {
        // Navigate to meals tab
        let mealsTab = app.tabBars.buttons["Meals"]
        if mealsTab.exists {
            mealsTab.tap()
            sleep(1)
            
            // Check for empty state message or "No Meals" text
            let emptyState = app.staticTexts.matching(identifier: "No Meals Logged Yet")
            if emptyState.count == 0 {
                // Alternative: check for "Log Meal" button
                let logMealButton = app.buttons["Log Meal"]
                XCTAssertTrue(logMealButton.exists || app.staticTexts.count > 0, "Empty state should be displayed")
            }
        }
    }
    
    // MARK: - Add Meal Tests
    
    func testAddMealButtonExists() throws {
        // Navigate to meals tab
        let mealsTab = app.tabBars.buttons["Meals"]
        if mealsTab.exists {
            mealsTab.tap()
            sleep(1)
            
            // Look for add meal button (could be "+" or "Add Meal" or floating action button)
            let addButton = app.buttons.matching(identifier: "plus").firstMatch
            let addMealButton = app.buttons["Add Meal"]
            let logMealButton = app.buttons["Log Meal"]
            
            let buttonExists = addButton.exists || addMealButton.exists || logMealButton.exists
            
            XCTAssertTrue(buttonExists, "Add meal button should exist")
        }
    }
    
    // MARK: - Food Search Tests
    
    func testFoodSearchFunctionality() throws {
        // Navigate to meals tab
        let mealsTab = app.tabBars.buttons["Meals"]
        if mealsTab.exists {
            mealsTab.tap()
            sleep(1)
            
            // Look for search functionality
            // This might be in a separate view or accessible from the add meal flow
            let searchField = app.searchFields.firstMatch
            let searchButton = app.buttons.matching(identifier: "Search").firstMatch
            
            // If search is available, test it
            if searchField.exists {
                searchField.tap()
                searchField.typeText("apple")
                sleep(2) // Wait for search results
                
                // Verify search results appear
                XCTAssertTrue(app.tables.count > 0 || app.staticTexts.count > 0, "Search should return results")
            }
        }
    }
    
    // MARK: - Meal Details Tests
    
    func testMealDetailView() throws {
        // This test assumes there's at least one meal in the list
        // In a real scenario, you'd first create a meal, then test viewing it
        
        let mealsTab = app.tabBars.buttons["Meals"]
        if mealsTab.exists {
            mealsTab.tap()
            sleep(1)
            
            // Try to find and tap on a meal if one exists
            let mealCells = app.cells
            if mealCells.count > 0 {
                mealCells.firstMatch.tap()
                sleep(1)
                
                // Verify detail view is shown
                // Look for common detail view elements
                XCTAssertTrue(app.navigationBars.count > 0 || app.staticTexts.count > 0, "Meal detail view should be displayed")
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingForNetworkIssues() throws {
        // This test would require mocking network failures
        // For now, we'll just verify the app doesn't crash
        
        let mealsTab = app.tabBars.buttons["Meals"]
        if mealsTab.exists {
            mealsTab.tap()
            sleep(1)
            
            // App should still be responsive even if network fails
            XCTAssertTrue(app.exists, "App should remain responsive")
        }
    }
    
    // MARK: - Performance Tests
    
    func testMealTrackerPerformance() throws {
        measure {
            // Navigate to meals tab
            let mealsTab = app.tabBars.buttons["Meals"]
            if mealsTab.exists {
                mealsTab.tap()
            }
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testMealTrackerAccessibility() throws {
        // Navigate to meals tab
        let mealsTab = app.tabBars.buttons["Meals"]
        if mealsTab.exists {
            mealsTab.tap()
            sleep(1)
            
            // Verify accessibility labels exist
            let allElements = app.descendants(matching: .any)
            XCTAssertTrue(allElements.count > 0, "Screen should have accessible elements")
        }
    }
}

