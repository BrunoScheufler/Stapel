import XCTest
import SwiftUI

@testable import Stapel


final class StapelTests: XCTestCase {
    func testInitialStackEmpty() {
        let s = Stack()
        XCTAssertEqual(s.views.count, 0)
    }
    
    func testRegister() throws {
        let s = Stack()
        s.register(pusher: 0)
        
        XCTAssertEqual(s.views.count, 1)
        
        let pusher = try XCTUnwrap(s.views[0])
        
        guard case .empty = pusher else {
            XCTFail("Expected pusher to be empty")
            return
        }
    }
    
    func testStackPush() throws {
        let s = AnyStack<String>()
        s.register(pusher: 0)
        
        let testView = "test"
        
        s.push(view: testView)
        
        let pushedView = try XCTUnwrap(s.views[0])
        
        guard case let .set(pushedViewContents) = pushedView else {
            XCTFail("Expected set view")
            return
        }
        
        XCTAssertEqual(pushedViewContents, testView)
    }
    
    func testStackPop() throws {
        let s = AnyStack<String>()
        s.views[0] = .set("test")
        
        s.pusherPop(0)
        
        let found = try XCTUnwrap(s.views[0])
        
        guard case .empty = found else {
            XCTFail("Expected pusher to be empty")
            return
        }
    }
    
    func testPopIdempotent() throws {
        let s = AnyStack<String>()
        s.views[0] = .set("test")
        
        s.pusherPop(0)
        s.pusherPop(0)
        s.pusherPop(0)
        
        let found = try XCTUnwrap(s.views[0])
        
        guard case .empty = found else {
            XCTFail("Expected pusher to be empty")
            return
        }
    }
    
    func testMulti() throws {
        let s = AnyStack<String>()
        
        func pusherSet(_ pusher: Int, _ to: String) throws {
            let detailPusher = try XCTUnwrap(s.views[pusher])
            
            guard case let .set(detailPusherSet) = detailPusher else {
                XCTFail("Expected pusher \(pusher) to be set")
                return
            }
            
            XCTAssertEqual(detailPusherSet, to)
        }
        
        func pusherEmpty(_ pusher: Int) throws {
            let detailPusher = try XCTUnwrap(s.views[pusher])
            
            guard case .empty = detailPusher else {
                XCTFail("Expected pusher \(pusher) to be empty")
                return
            }
        }
        
        func pusherUnregistered(_ pusher: Int) {
            XCTAssertFalse(s.views.keys.contains(pusher))
        }
        
        XCTAssertEqual(s.views.count, 0)
        
        s.register(pusher: 0)
        
        s.push(view: "list")
        s.register(pusher: 1)
        
        XCTAssertEqual(s.views.count, 2)
        
        s.push(view: "detail")
        s.register(pusher: 2)
        
        XCTAssertEqual(s.views.count, 3)
        
        s.push(view: "adhoc")
        // this view does not register a pusher
        
        XCTAssertEqual(s.views.count, 3)
        
        try pusherSet(0, "list")
        try pusherSet(1, "detail")
        try pusherSet(2, "adhoc")
        
        // close adhoc
        s.pusherPop(2)
        
        // we don't expect detail pusher to be removed yet as
        // it is empty after the pop
        
        XCTAssertEqual(s.views.count, 3)
        
        try pusherSet(0, "list")
        try pusherSet(1, "detail")
        try pusherEmpty(2)
        
        // close detail
        s.pusherPop(1)
        
        // now we're viewing the list view (with an empty pusher 1)
        // detail pusher should have been removed (count decreased)
        
        XCTAssertEqual(s.views.count, 2)
        
        try pusherSet(0, "list")
        try pusherEmpty(1)
        pusherUnregistered(2)
        
        s.push(view: "another")
        // this view does not register a pusher
        
        try pusherSet(0, "list")
        try pusherSet(1, "another")
    }
    
    
    static var allTests = [
        ("testInitialStackEmpty", testInitialStackEmpty),
        ("testStackPush", testStackPush),
        ("testStackPop", testStackPop),
        ("testPopIdempotent", testPopIdempotent),
        ("testMulti", testMulti)
    ]
}
