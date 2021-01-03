import XCTest
import SwiftUI

@testable import Stapel


final class StapelTests: XCTestCase {
    // Creating stack should yield empty stack
    func testInitialStackEmpty() {
        let s = Stack()
        XCTAssertEqual(s.pushers.count, 0)
    }
    
    // Registering pusher should increase stack count and create empty pusher state
    func testRegister() throws {
        let s = Stack()
        s.register(0)
        
        XCTAssertEqual(s.pushers.count, 1)
        
        let pusher = try XCTUnwrap(s.pushers[0])
        
        guard case .empty = pusher.view else {
            XCTFail("Expected pusher to be empty")
            return
        }
    }
    
    // Pushing view on stack should assign view to active pusher
    func testStackPush() throws {
        let s = AnyStack<String>()
        s.register(0)
        
        let testView = "test"
        
        s.push(view: testView)
        
        let rootPusher = try XCTUnwrap(s.pushers[0])
        
        guard case let .set(pushedViewContents) = rootPusher.view else {
            XCTFail("Expected set view")
            return
        }
        
        XCTAssertEqual(pushedViewContents, testView)
    }
    
    // Popping view should empty state of active pusher
    func testStackPop() throws {
        let s = AnyStack<String>()
        s.pushers[0] = PusherState(.set("test"))
        
        s.pusherPop(0)
        
        let found = try XCTUnwrap(s.pushers[0])
        
        guard case .empty = found.view else {
            XCTFail("Expected pusher to be empty")
            return
        }
    }
    
    // Popping the same pusher multiple times should not change the outcome
    // This is just a safeguard against SwiftUI acting weird, although this shouldn't happen
    // in StackNavigation mode
    func testPopIdempotent() throws {
        let s = AnyStack<String>()
        s.pushers[0] = PusherState(.set("test"))
        
        s.pusherPop(0)
        s.pusherPop(0)
        s.pusherPop(0)
        
        let found = try XCTUnwrap(s.pushers[0])
        
        guard case .empty = found.view else {
            XCTFail("Expected pusher to be empty")
            return
        }
    }
    
    // Test expected use case of nested navigation with multiple push and pop operations
    func testMulti() throws {
        let s = AnyStack<String>()
        
        func pusherSet(_ pusher: Int, _ to: String) throws {
            let detailPusher = try XCTUnwrap(s.pushers[pusher])
            
            guard case let .set(detailPusherSet) = detailPusher.view else {
                XCTFail("Expected pusher \(pusher) to be set")
                return
            }
            
            XCTAssertEqual(detailPusherSet, to)
        }
        
        func pusherEmpty(_ pusher: Int) throws {
            let detailPusher = try XCTUnwrap(s.pushers[pusher])
            
            guard case .empty = detailPusher.view else {
                XCTFail("Expected pusher \(pusher) to be empty")
                return
            }
        }
        
        func pusherUnregistered(_ pusher: Int) {
            XCTAssertFalse(s.pushers.keys.contains(pusher))
        }
        
        XCTAssertEqual(s.pushers.count, 0)
        
        s.register(0)
        
        s.push(view: "list")
        s.register(1)
        
        XCTAssertEqual(s.pushers.count, 2)
        
        s.push(view: "detail")
        s.register(2)
        
        XCTAssertEqual(s.pushers.count, 3)
        
        s.push(view: "adhoc")
        // this view does not register a pusher
        
        XCTAssertEqual(s.pushers.count, 3)
        
        try pusherSet(0, "list")
        try pusherSet(1, "detail")
        try pusherSet(2, "adhoc")
        
        // close adhoc
        s.pusherPop(2)
        
        // we don't expect detail pusher to be removed yet as
        // it is empty after the pop
        
        XCTAssertEqual(s.pushers.count, 3)
        
        try pusherSet(0, "list")
        try pusherSet(1, "detail")
        try pusherEmpty(2)
        
        // close detail
        s.pusherPop(1)
        
        // now we're viewing the list view (with an empty pusher 1)
        // detail pusher should have been removed (count decreased)
        
        XCTAssertEqual(s.pushers.count, 2)
        
        try pusherSet(0, "list")
        try pusherEmpty(1)
        pusherUnregistered(2)
        
        s.push(view: "another")
        // this view does not register a pusher
        
        try pusherSet(0, "list")
        try pusherSet(1, "another")
    }
    
    // Test evaluation with default (no eval func supplied)
    func testEvaluateEmpty() {
        let s = AnyStack<String>()
        s.register(0)
        XCTAssertTrue(s.evaluate())
    }
    
    // Test evaluation with always-true eval func
    func testEvaluateAlways() {
        let s = AnyStack<String>()
        s.register(0, { (context) -> Bool in
            return true
        })
        
        XCTAssertTrue(s.evaluate())
        XCTAssertTrue(s.evaluate(["still": true]))
    }
    
    // Test evaluation with context-dependent eval func, success case
    func testEvaluateOnContextTruthy() {
        let s = AnyStack<String>()
        s.register(0, { (context) -> Bool in
            guard let hasValue = context["expected"] else {
                return false
            }
            guard let asBool = hasValue as? Bool else {
                return false
            }
            return asBool
        })
        
        XCTAssertTrue(s.evaluate(["expected": true]))
    }
    
    // Test evaluation with context-dependent eval func, fail case
    func testEvaluateOnContextFalsy() {
        let s = AnyStack<String>()
        s.register(0, { (context) -> Bool in
            guard let hasValue = context["expected"] else {
                return false
            }
            guard let asBool = hasValue as? Bool else {
                return false
            }
            return asBool
        })
        
        XCTAssertFalse(s.evaluate(["expected": "invalid"]))
    }
    
    // Test evaluation with always-false eval func
    func testEvaluateNever() {
        let s = AnyStack<String>()
        s.register(0, { (context) -> Bool in
            return false
        })
        
        XCTAssertFalse(s.evaluate())
        XCTAssertFalse(s.evaluate(["still": false]))
    }
    
    
    static var allTests = [
        ("testInitialStackEmpty", testInitialStackEmpty),
        ("testStackPush", testStackPush),
        ("testStackPop", testStackPop),
        ("testPopIdempotent", testPopIdempotent),
        ("testMulti", testMulti),
        ("testEvaluateEmpty", testEvaluateEmpty),
        ("testEvaluateOnContextTruthy", testEvaluateOnContextTruthy),
        ("testEvaluateOnContextFalsy", testEvaluateOnContextFalsy),
        ("testEvaluateAlways", testEvaluateAlways),
        ("testEvaluateNever", testEvaluateNever),
    ]
}
