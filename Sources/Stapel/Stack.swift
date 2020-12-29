import SwiftUI

enum StackViewType<T> {
    case empty
    case set(T)
}

public class AnyStack<T>: ObservableObject {
    @Published var views: [Int: StackViewType<T>]
    
    public init() {
        self.views = [:]
    }
    
    func activePusher() -> Int? {
        guard self.views.count > 0 else {
            return nil
        }
        
        let sortedKeys = self.views.keys.sorted()
        
        let activePusherId = sortedKeys[sortedKeys.count - 1]
        
        return activePusherId
    }
    
    func rootPusher() -> Int? {
        guard self.views.count > 0 else {
            return nil
        }
        
        let sortedKeys = self.views.keys.sorted()
        
        let rootPusherId = sortedKeys[0]
        
        return rootPusherId
    }
    
    public func push(view: T) -> Void {
        guard self.views.count > 0 else {
            return
        }
        
        let sortedKeys = self.views.keys.sorted()
        
        let pusherId = sortedKeys[sortedKeys.count - 1]
        
        withAnimation {
            self.views[pusherId] = .set(view)
        }
    }
    
    func pusherPop(_ pusher: Int) -> Void {
        self.views[pusher] = .empty
        
        let sortedKeys = self.views.keys.sorted()
        
        // Remove all views after popped pusher, this is to prevent old empty pushers from being registered
        sortedKeys.filter { (key) -> Bool in
            return key > pusher
        }.forEach({ key in
            self.views.removeValue(forKey: key)
        })
    }
    
    func register(pusher: Int) -> Void {
        guard !self.views.keys.contains(pusher) else {
            return
        }
        
        self.views[pusher] = .empty
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
///         // Pass down stack to access it anywhere, this is required!
///         .environmentObject(stack)
///       }
///     }
///
public class Stack: AnyStack<AnyView> {
    
}
