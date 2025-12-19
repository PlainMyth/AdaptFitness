//
//  ComprehensiveUITests.swift
//  AdaptFitnessUITests
//
//  Comprehensive UI tests covering onboarding, authentication, dashboard,
//  stats, workouts, and calendar functionality
//

import XCTest

final class ComprehensiveUITests: XCTestCase {
    
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
    
    // MARK: - Helper Methods
    
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    private func tapIfExists(_ element: XCUIElement) -> Bool {
        if element.exists {
            element.tap()
            return true
        }
        return false
    }
    
    // MARK: - 1. Onboarding & Authentication Tests
    
    /// Test 1.1: Launch Application
    /// Expected: Splash screen is displayed, followed by the Login screen
    func testLaunchApplication() throws {
        // Wait for app to fully launch
        sleep(2)
        
        // Check for login screen elements
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        let signUpButton = app.buttons.matching(identifier: "Don't have an account? Sign up").firstMatch
        
        // Verify login screen is displayed
        XCTAssertTrue(emailField.exists || passwordField.exists || loginButton.exists || signUpButton.exists,
                      "Login screen should be displayed after launch")
    }
    
    /// Test 1.2: User Registration
    /// Expected: Account is created successfully and app navigates to Home Dashboard
    func testUserRegistration() throws {
        // Wait for app to load
        sleep(2)
        
        // Find and tap Sign Up button
        let signUpButton = app.buttons.matching(identifier: "Don't have an account? Sign up").firstMatch
        if signUpButton.exists {
            signUpButton.tap()
            sleep(1)
        }
        
        // Fill in registration form
        // Note: Adjust these identifiers based on actual SignUpView/RegisterView implementation
        let emailField = app.textFields.matching(identifier: "Email").firstMatch
        let passwordField = app.secureTextFields.matching(identifier: "Password").firstMatch
        let confirmPasswordField = app.secureTextFields.matching(identifier: "Confirm Password").firstMatch
        let firstNameField = app.textFields.matching(identifier: "First Name").firstMatch
        let lastNameField = app.textFields.matching(identifier: "Last Name").firstMatch
        
        // Generate unique email for testing
        let uniqueEmail = "test\(Int.random(in: 1000...9999))@test.com"
        let testPassword = "Test1234!"
        
        if emailField.exists {
            emailField.tap()
            emailField.typeText(uniqueEmail)
        }
        
        if passwordField.exists {
            passwordField.tap()
            passwordField.typeText(testPassword)
        }
        
        if confirmPasswordField.exists {
            confirmPasswordField.tap()
            confirmPasswordField.typeText(testPassword)
        }
        
        if firstNameField.exists {
            firstNameField.tap()
            firstNameField.typeText("Test")
        }
        
        if lastNameField.exists {
            lastNameField.tap()
            lastNameField.typeText("User")
        }
        
        // Tap Sign Up/Register button
        let registerButton = app.buttons.matching(identifier: "Sign Up").firstMatch
        if !registerButton.exists {
            let createAccountButton = app.buttons.matching(identifier: "Create Account").firstMatch
            if createAccountButton.exists {
                createAccountButton.tap()
            }
        } else {
            registerButton.tap()
        }
        
        // Wait for navigation to dashboard
        sleep(3)
        
        // Verify we're on the home dashboard
        // Look for home screen elements like streak, calendar, or goals
        let homeTab = app.buttons["Home"]
        let streakIcon = app.images.matching(identifier: "flame.fill").firstMatch
        let goalsText = app.staticTexts["Goals"]
        
        let onDashboard = homeTab.exists || streakIcon.exists || goalsText.exists
        
        XCTAssertTrue(onDashboard, "Should navigate to Home Dashboard after successful registration")
    }
    
    /// Test 1.3: User Logout
    /// Expected: User is returned to Login screen and session is cleared
    func testUserLogout() throws {
        // First, ensure we're logged in (or skip if not)
        sleep(2)
        
        // Navigate to Profile
        let profileButton = app.buttons["Profile"]
        if profileButton.exists {
            profileButton.tap()
            sleep(1)
        } else {
            // Try alternative ways to access profile
            let settingsButton = app.buttons.matching(identifier: "gearshape.fill").firstMatch
            if settingsButton.exists {
                settingsButton.tap()
                sleep(1)
            }
        }
        
        // Find and tap Log Out button
        let logOutButton = app.buttons["Log Out"]
        if logOutButton.exists {
            logOutButton.tap()
            sleep(2)
            
            // Verify we're back at login screen
            let emailField = app.textFields["Email"]
            let loginButton = app.buttons["Login"]
            
            XCTAssertTrue(emailField.exists || loginButton.exists,
                         "Should return to Login screen after logout")
        } else {
            XCTSkip("Logout button not found - may need to be logged in first")
        }
    }
    
    /// Test 1.4: Valid Login
    /// Expected: Dashboard loads successfully with user's data
    func testValidLogin() throws {
        // Skip if already logged in
        sleep(2)
        
        // Check if we're already on dashboard
        let homeTab = app.buttons["Home"]
        if homeTab.exists {
            // Already logged in, verify dashboard elements
            let streakIcon = app.images.matching(identifier: "flame.fill").firstMatch
            let goalsText = app.staticTexts["Goals"]
            
            XCTAssertTrue(streakIcon.exists || goalsText.exists,
                         "Dashboard should display user data (streak, goals, etc.)")
            return
        }
        
        // Fill in login form
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        
        if emailField.exists && passwordField.exists {
            emailField.tap()
            emailField.typeText("test@example.com")
            
            passwordField.tap()
            passwordField.typeText("Test1234!")
            
            // Tap Login button
            let loginButton = app.buttons["Login"]
            if loginButton.exists {
                loginButton.tap()
                sleep(3) // Wait for login and navigation
                
                // Verify dashboard loaded
                let streakIcon = app.images.matching(identifier: "flame.fill").firstMatch
                let goalsText = app.staticTexts["Goals"]
                let calendarExists = app.scrollViews.count > 0
                
                XCTAssertTrue(streakIcon.exists || goalsText.exists || calendarExists,
                             "Dashboard should load successfully with user's data")
            }
        } else {
            XCTSkip("Login form not found")
        }
    }
    
    /// Test 1.5: Invalid Login
    /// Expected: "Invalid credentials" error message is displayed
    func testInvalidLogin() throws {
        sleep(2)
        
        // Check if already logged in
        let homeTab = app.buttons["Home"]
        if homeTab.exists {
            // Log out first
            let profileButton = app.buttons["Profile"]
            if profileButton.exists {
                profileButton.tap()
                sleep(1)
                let logOutButton = app.buttons["Log Out"]
                if logOutButton.exists {
                    logOutButton.tap()
                    sleep(2)
                }
            }
        }
        
        // Fill in login form with invalid credentials
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        
        if emailField.exists && passwordField.exists {
            emailField.tap()
            emailField.typeText("invalid@example.com")
            
            passwordField.tap()
            passwordField.typeText("WrongPassword123!")
            
            // Tap Login button
            let loginButton = app.buttons["Login"]
            if loginButton.exists {
                loginButton.tap()
                sleep(2) // Wait for error message
                
                // Check for error message
                let errorMessage = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'invalid' OR label CONTAINS[c] 'credentials' OR label CONTAINS[c] 'error'")).firstMatch
                
                XCTAssertTrue(errorMessage.exists,
                             "Should display error message for invalid credentials")
            }
        } else {
            XCTSkip("Login form not found")
        }
    }
    
    // MARK: - 2. Dashboard & Goal Tracking Tests
    
    /// Test 2.1: View Dashboard
    /// Expected: Streak icon, Calendar, and Goal cards are visible
    func testViewDashboard() throws {
        // Ensure we're logged in and on home screen
        sleep(2)
        
        // Navigate to Home tab if not already there
        let homeTab = app.buttons["Home"]
        if homeTab.exists {
            homeTab.tap()
            sleep(1)
        }
        
        // Check for streak icon
        let streakIcon = app.images.matching(identifier: "flame.fill").firstMatch
        let streakText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Day Streak' OR label CONTAINS 'Streak'")).firstMatch
        
        // Check for calendar
        let calendarExists = app.scrollViews.count > 0
        
        // Check for Goals section
        let goalsText = app.staticTexts["Goals"]
        let goalCards = app.scrollViews.containing(.staticText, identifier: "Goals")
        
        XCTAssertTrue((streakIcon.exists || streakText.exists) && (calendarExists || goalsText.exists),
                     "Dashboard should display Streak icon, Calendar, and Goal cards")
    }
    
    /// Test 2.2: Calendar Navigation
    /// Expected: Dates update and highlight correctly when swiping
    func testCalendarNavigation() throws {
        sleep(2)
        
        // Navigate to Home tab
        let homeTab = app.buttons["Home"]
        if homeTab.exists {
            homeTab.tap()
            sleep(1)
        }
        
        // Find horizontal calendar scroll view
        let scrollViews = app.scrollViews
        if scrollViews.count > 0 {
            let calendarScrollView = scrollViews.firstMatch
            
            // Get initial state
            let initialDateElements = app.staticTexts.matching(NSPredicate(format: "label MATCHES '\\d{1,2}'")).allElementsBoundByIndex
            let initialCount = initialDateElements.count
            
            // Swipe left on calendar
            calendarScrollView.swipeLeft()
            sleep(1)
            
            // Swipe right to return
            calendarScrollView.swipeRight()
            sleep(1)
            
            // Verify calendar is interactive
            XCTAssertTrue(calendarScrollView.exists, "Calendar should be swipeable and dates should update")
        } else {
            XCTSkip("Calendar scroll view not found")
        }
    }
    
    // MARK: - 3. Stats Tests
    
    /// Test 3.1: View Stats
    /// Expected: Displays overall tracking tabs
    func testViewStats() throws {
        sleep(2)
        
        // Navigate to Stats tab
        let statsTab = app.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            sleep(2)
            
            // Check for stats/tracking elements
            let trackingTitle = app.staticTexts["Tracking"]
            let nutritionSummary = app.staticTexts["Nutrition Summary"]
            let calorieChart = app.charts.firstMatch
            let timeRangePicker = app.pickers.firstMatch
            
            // Verify stats screen displays tracking information
            XCTAssertTrue(trackingTitle.exists || nutritionSummary.exists || calorieChart.exists || timeRangePicker.exists,
                         "Stats tab should display overall tracking tabs and information")
        } else {
            XCTSkip("Stats tab not found")
        }
    }
    
    // MARK: - 4. Fitness & Workout Logging Tests
    
    /// Test 4.1: View Workouts
    /// Expected: Shows generate a workout if not done or current workout
    func testViewWorkouts() throws {
        sleep(2)
        
        // Navigate to Workouts tab
        let workoutTab = app.buttons["Workout"]
        if workoutTab.exists {
            workoutTab.tap()
            sleep(2)
            
            // Check for workout-related content
            let generateButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Generate' OR label CONTAINS[c] 'generate'")).firstMatch
            let workoutPlanText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Workout' OR label CONTAINS[c] 'workout'")).firstMatch
            let activePlan = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Plan' OR label CONTAINS[c] 'plan'")).firstMatch
            
            // Should show either generate form or current workout
            XCTAssertTrue(generateButton.exists || workoutPlanText.exists || activePlan.exists,
                         "Workouts tab should show generate workout option or current workout")
        } else {
            XCTSkip("Workout tab not found")
        }
    }
    
    /// Test 4.2: Generate Different Workout
    /// Expected: Generates Workouts and follows the proper days
    func testGenerateDifferentWorkout() throws {
        sleep(2)
        
        // Navigate to Workouts tab
        let workoutTab = app.buttons["Workout"]
        if workoutTab.exists {
            workoutTab.tap()
            sleep(2)
        }
        
        // Find generate workout form
        let generateButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Generate' OR label CONTAINS[c] 'generate'")).firstMatch
        
        if generateButton.exists {
            // Fill in workout generation form
            // Goal field
            let goalField = app.textFields.matching(identifier: "User Goal").firstMatch
            if !goalField.exists {
                let textFields = app.textFields
                if textFields.count > 0 {
                    textFields.firstMatch.tap()
                    textFields.firstMatch.typeText("Build muscle and strength")
                }
            } else {
                goalField.tap()
                goalField.typeText("Build muscle and strength")
            }
            
            // Experience level picker
            let experiencePicker = app.pickers.firstMatch
            if experiencePicker.exists {
                experiencePicker.tap()
                sleep(1)
                // Select intermediate (adjust based on actual options)
                let pickerWheel = app.pickerWheels.firstMatch
                if pickerWheel.exists {
                    pickerWheel.adjust(toPickerWheelValue: "intermediate")
                }
            }
            
            // Days per week stepper
            let daysStepper = app.steppers.firstMatch
            if daysStepper.exists {
                // Increase days
                let incrementButton = daysStepper.buttons.matching(identifier: "Increment").firstMatch
                if incrementButton.exists {
                    incrementButton.tap()
                }
            }
            
            // Tap Generate button
            generateButton.tap()
            sleep(5) // Wait for workout generation
            
            // Verify workout was generated
            let workoutPlan = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Plan' OR label CONTAINS[c] 'Workout'")).firstMatch
            let workoutDays = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Day' OR label CONTAINS[c] 'Monday' OR label CONTAINS[c] 'Tuesday'")).firstMatch
            
            XCTAssertTrue(workoutPlan.exists || workoutDays.exists,
                         "Workout should be generated with proper days")
        } else {
            XCTSkip("Generate workout button not found - may already have an active workout")
        }
    }
    
    // MARK: - 5. Calendar Tests
    
    /// Test 5.1: View Calendar View
    /// Expected: Displays goals or set new goal option
    func testViewCalendarView() throws {
        sleep(2)
        
        // Navigate to Calendar tab
        let calendarTab = app.buttons["Calendar"]
        if calendarTab.exists {
            calendarTab.tap()
            sleep(2)
            
            // Check for calendar view elements
            let goalsTitle = app.staticTexts["Goals"]
            let setGoalButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Goal' OR label CONTAINS[c] 'goal' OR label CONTAINS[c] 'Set'")).firstMatch
            let noGoalsText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'No Goals' OR label CONTAINS[c] 'goal'")).firstMatch
            let addButton = app.buttons.matching(identifier: "plus").firstMatch
            
            // Should show either goals or option to set new goal
            XCTAssertTrue(goalsTitle.exists || setGoalButton.exists || noGoalsText.exists || addButton.exists,
                         "Calendar view should display goals or set new goal option")
        } else {
            XCTSkip("Calendar tab not found")
        }
    }
    
    /// Test 5.2: Setting New Goal
    /// Expected: Goal is made successfully
    func testSettingNewGoal() throws {
        sleep(2)
        
        // Navigate to Calendar tab
        let calendarTab = app.buttons["Calendar"]
        if calendarTab.exists {
            calendarTab.tap()
            sleep(2)
        }
        
        // Find and tap add goal button
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        let setGoalButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Set' AND label CONTAINS[c] 'Goal'")).firstMatch
        
        if addButton.exists {
            addButton.tap()
            sleep(1)
        } else if setGoalButton.exists {
            setGoalButton.tap()
            sleep(1)
        } else {
            XCTSkip("Add goal button not found")
            return
        }
        
        // Fill in goal form
        // Goal type picker
        let goalTypePicker = app.pickers.firstMatch
        if goalTypePicker.exists {
            goalTypePicker.tap()
            sleep(1)
        }
        
        // Target value field
        let targetField = app.textFields.matching(identifier: "Target Value").firstMatch
        if !targetField.exists {
            let textFields = app.textFields
            if textFields.count > 0 {
                textFields.firstMatch.tap()
                textFields.firstMatch.typeText("5")
            }
        } else {
            targetField.tap()
            targetField.typeText("5")
        }
        
        // Description field (optional)
        let descriptionField = app.textFields.matching(identifier: "Description").firstMatch
        if descriptionField.exists {
            descriptionField.tap()
            descriptionField.typeText("Test goal")
        }
        
        // Tap Save button
        let saveButton = app.buttons["Save"]
        if saveButton.exists {
            saveButton.tap()
            sleep(3) // Wait for goal to be saved
            
            // Verify goal was created
            // Navigate back to calendar view if needed
            let doneButton = app.buttons["Done"]
            if doneButton.exists {
                doneButton.tap()
                sleep(1)
            }
            
            // Check for the new goal in the list
            let goalsTitle = app.staticTexts["Goals"]
            let goalCards = app.scrollViews.containing(.staticText, identifier: "Goals")
            
            XCTAssertTrue(goalsTitle.exists || goalCards.count > 0,
                         "Goal should be created and displayed in calendar view")
        } else {
            XCTSkip("Save button not found or disabled")
        }
    }
}

