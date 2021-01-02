import SwiftUI

struct PusherState<T> {
    var view: StackViewType<T>
    var evaluator: (([String: Any]) -> Bool)?
    
    init(_ view: StackViewType<T>) {
        self.view = view
    }
}

struct Pusher: View {
    // Assign time-based identifier to get incrementing
    // values for subsequent Pusher views instack. This is extremly
    // important for the system to work, although it would be great to use
    // something like a classic counter, which I couldn't get working (yet)
    @State var id: Int = Int((Date().timeIntervalSince1970 * 1000.0).rounded())
    
    @EnvironmentObject var stack: Stack
    
    @State var isActive = true
    
    func retrieveViewToRender() -> (AnyView?) {
        guard let hasEntry = stack.pushers[id] else {
            return nil
        }
        
        guard case let .set(withView) = hasEntry.view else {
            return nil
        }
        
        return withView
    }
    
    var body: some View {
        let viewToRender = retrieveViewToRender()
        NavigationLink(
            destination: viewToRender ?? AnyView(EmptyView()),
            // If no view should be rendered, don't be bothered with state management
            isActive: viewToRender == nil ? .constant(false) : $isActive,
            label: {
                EmptyView()
            })
            // On appear, register in stack. If the current pusher
            // is already registered, this will be a noop
            .onAppear {
                stack.register(pusher: id)
            }
            // When the view is popped (value changes from true to false),
            // we'll pop the stack as well and reset the active flag
            .onChange(of: isActive, perform: { value in
                guard !value else {
                    return
                }
                
                // Pop view from stack, set pusher to empty
                withAnimation {
                    stack.pusherPop(id)
                    isActive = true
                }
            })
    }
}

/// Simple wrapper that automatically renders Pusher in VStack, after content.
///
/// - Parameter content: The view(s) to render
///
///     WithPusher {
///       Text("Root View")
///     }
public struct WithPusher<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack {
            content
            Pusher()
        }
    }
}
