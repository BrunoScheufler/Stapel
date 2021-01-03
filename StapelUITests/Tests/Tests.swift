import XCTest

class Tests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func launchApp(_ scenario: String = "simple") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["test_scenario"] = scenario
        app.launch()
        
        return app
    }
    
    func testWithoutVStack() {
        let app = launchApp("without_vstack")
        
        XCTAssert(app.staticTexts["Should be visible"].exists)
        XCTAssert(app.staticTexts["This too"].exists)
    }
    
    func testPush() throws {
        let app = launchApp()
        
        XCTAssert(app.buttons["Push"].exists)
        app.buttons["Push"].tap()
        XCTAssert(app.staticTexts["Pushed view"].exists)
    }
    
    func testPop() throws {
        let app = launchApp()
        
        
        XCTAssert(app.staticTexts["Hello world!"].exists)
        
        let pushButton = app.buttons["Push"]
        pushButton.tap()
        
        XCTAssert(app.staticTexts["Pushed view"].exists)
        
        let backButton = app.navigationBars["_TtGC7SwiftUIP13$7fff5767130428DestinationHosting"].buttons["Back"]
        backButton.tap()
        
        XCTAssert(app.staticTexts["Hello world!"].exists)
        XCTAssert(!app.staticTexts["Pushed view"].exists)
        
        pushButton.tap()
        XCTAssert(app.staticTexts["Pushed view"].exists)
        XCTAssert(!app.staticTexts["Hello world!"].exists)
        
        backButton.tap()
        
        XCTAssert(app.staticTexts["Hello world!"].exists)
        XCTAssert(!app.staticTexts["Pushed view"].exists)
    }
    
    func testNestedNavigation() {
        let app = launchApp("nested")
        
        XCTAssert(app.staticTexts["Root View"].exists)
        
        let toSecond = app.buttons["Push another view"]
        toSecond.tap()
        
        XCTAssert(!app.staticTexts["Root View"].exists)
        XCTAssert(app.staticTexts["Second view"].exists)
        
        let toThird = app.buttons["Push yet another view"]
        toThird.tap()
        
        XCTAssert(!app.staticTexts["Second view"].exists)
        XCTAssert(app.staticTexts["Third view"].exists)
        
        
        let toFourth = app.buttons["And another view"]
        toFourth.tap()
        
        XCTAssert(app.staticTexts["Fourth view"].exists)
        
        let backToThird = app.navigationBars["Fourth view"].buttons["Third view"]
        backToThird.tap()
        
        XCTAssert(!app.staticTexts["Fourth view"].exists)
        XCTAssert(app.staticTexts["Third view"].exists)
        
        let backToSecond = app.navigationBars["Third view"].buttons["Second view"]
        backToSecond.tap()
                
        XCTAssert(!app.staticTexts["Third view"].exists)
        XCTAssert(app.staticTexts["Second view"].exists)
        
        let backToFirst = app.navigationBars["Second view"].buttons["Root view"]
        backToFirst.tap()
        
        XCTAssert(!app.staticTexts["Second view"].exists)
        XCTAssert(app.staticTexts["Root view"].exists)
        
        toSecond.tap()
        toThird.tap()
        toFourth.tap()
        backToThird.tap()
        toFourth.tap()
        backToThird.tap()
        backToSecond.tap()
        backToFirst.tap()
        toSecond.tap()
        backToFirst.tap()
    }
    
    func testWithEvaluateRootTruthy() {
        let app = launchApp("evaluate_root")

        XCTAssert(app.staticTexts["Root view"].exists)
        
        let shouldntPush = app.buttons["Push falsy"]
        shouldntPush.tap()
        
        XCTAssert(app.staticTexts["Root view"].exists)
        XCTAssert(!app.staticTexts["No-op"].exists)
    }
    
    func testWithEvaluateRootFalsy() {
        let app = launchApp("evaluate_root")

        XCTAssert(app.staticTexts["Root view"].exists)
        
        let shouldntPush = app.buttons["Push truthy"]
        shouldntPush.tap()
        
        XCTAssert(!app.staticTexts["Root view"].exists)
        XCTAssert(app.staticTexts["Pushed with evaluation"].exists)

    }
    
    func testWithEvaluateNestedTruthy() {
        let app = launchApp("evaluate_nested")

        XCTAssert(app.staticTexts["Root view"].exists)
        
        app.buttons["Push"].tap()

        XCTAssert(!app.staticTexts["Root view"].exists)
        XCTAssert(app.staticTexts["Second view"].exists)

        let shouldntPush = app.buttons["Push falsy"]
        shouldntPush.tap()
        
        XCTAssert(app.staticTexts["Second view"].exists)
        XCTAssert(!app.staticTexts["No-op"].exists)
    }
    
    func testWithEvaluateNestedFalsy() {
        let app = launchApp("evaluate_nested")

        XCTAssert(app.staticTexts["Root view"].exists)
        
        app.buttons["Push"].tap()

        XCTAssert(!app.staticTexts["Root view"].exists)
        XCTAssert(app.staticTexts["Second view"].exists)
        
        let shouldntPush = app.buttons["Push truthy"]
        shouldntPush.tap()
        
        XCTAssert(!app.staticTexts["Second view"].exists)
        XCTAssert(app.staticTexts["Pushed with evaluation"].exists)

    }
}
