import SwiftUI

enum StackViewType<T> {
    case empty
    case set(T)
}

public class AnyStack<T>: ObservableObject {
    // Store registered pusher states
    @Published var pushers: [Int: PusherState<T>]
    
    public init() {
        self.pushers = [:]
    }
    
    func activePusher() -> Int? {
        guard self.pushers.count > 0 else {
            return nil
        }
        
        let sortedKeys = self.pushers.keys.sorted()
        
        let activePusherId = sortedKeys[sortedKeys.count - 1]
        
        return activePusherId
    }
    
    /// Push a view onto the stack
    ///
    /// - Parameter view: The view to push onto the stack
    /// - Parameter context: Optional context map passed to evaluation function of pusher if supplied. If eval func returns false, view will not be pushed.
    ///
    ///     WithPusher {
    ///       Text("Root View")
    ///     }
    public func push(view: T, context: [String: Any] = [:]) -> Void {
        // Find active pusher to assign view to
        guard let pusherId = activePusher() else {
            return
        }
        
        // Make sure we should push the view, otherwise return early
        guard evaluate(context) else {
            return
        }
        
        updatePusherView(pusherId, .set(view))    
    }
    
    /// Evaluate whether a given context would be pushed onto the stack
    ///
    /// - Parameter context: Optional context map passed to evaluation function of pusher if supplied.
    ///   If eval func returns false, view would not be pushed.
    ///   If no pusher is registered, `evaluate` will also return false.
    ///   If no eval func is supplied, `evaluate` will return true.
    /// - Returns: Whether view would be pushed onto the stack
    ///
    public func evaluate(_ context: [String: Any] = [:]) -> Bool {
        // Find pusher that would be targeted
        guard let pusherId = activePusher() else {
            return false
        }
        
        // Retrieve pusher state (should exist)
        guard let state = self.pushers[pusherId] else {
            return false
        }
        
        // Retrieve evaluator or return early
        guard let eval = state.evaluator else {
            // No evaluator supplied, return true, always push views
            return true
        }
        
        // Evaluate
        return eval(context)
    }
    
    func updatePusherView(_ pusherId: Int, _ viewType: StackViewType<T>) {
        guard var state = self.pushers[pusherId] else {
            return
        }
        
        state.view = viewType
        
        self.pushers[pusherId] = state
    }
    
    func pusherPop(_ pusher: Int) -> Void {
        updatePusherView(pusher, .empty)
        
        let sortedKeys = self.pushers.keys.sorted()
        
        // Remove all views after popped pusher, this is to prevent old empty pushers from being registered
        sortedKeys.filter { (key) -> Bool in
            return key > pusher
        }.forEach({ key in
            self.pushers.removeValue(forKey: key)
        })
    }
    
    func register(_ pusher: Int, _ evaluate: PusherEvalFunc? = nil) -> Void {
        guard !self.pushers.keys.contains(pusher) else {
            return
        }
        
        self.pushers[pusher] = PusherState(.empty, evaluate)
    }
}

/// The virtual stack Stapel uses to manage internal state and expose programmatic navigation features
///
///     import SwiftUI
///     import Stapel
///
///     struct ContentView: View {
///       @StateObject var stack = Stack()
///
///       var body: some View {
///         WithStapel {
///           Text("Root View")
///         }
///         // Pass down the stack to access it anywhere, this is required!
///         .environmentObject(stack)
///       }
///     }
///
public class Stack: AnyStack<AnyView> {
    
}
