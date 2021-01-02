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
    
    func rootPusher() -> Int? {
        guard self.pushers.count > 0 else {
            return nil
        }
        
        let sortedKeys = self.pushers.keys.sorted()
        
        let rootPusherId = sortedKeys[0]
        
        return rootPusherId
    }
    
    public func push(view: T) -> Void {
        guard self.pushers.count > 0 else {
            return
        }
        
        let sortedKeys = self.pushers.keys.sorted()
        
        let pusherId = sortedKeys[sortedKeys.count - 1]
        
        withAnimation {
            updatePusherView(pusherId, .set(view))
        }
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
    
    func register(pusher: Int) -> Void {
        guard !self.pushers.keys.contains(pusher) else {
            return
        }
        
        self.pushers[pusher] = PusherState(.empty)
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
