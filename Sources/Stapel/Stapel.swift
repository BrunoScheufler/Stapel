import SwiftUI

/// Top-level navigation view required for Stapel
///
///     WithStapel {
///       Text("Root View")
///     }
///
/// Will simply render a navigation view with required view style set. This can still be modified to your preferences.
///
/// It will also initialize a root pusher to push your first layer of views.
///
@available(iOS 14, *)
@available(macOS, unavailable) // Unfortunately, StackNavigationStyle is not available on macOS
public struct WithStapel<Content: View>: View {
    let shouldPush: PusherEvalFunc?
    let content: Content
    
    /// Create WithStapel view
    ///
    /// - Parameter content: Views to render as children
    ///
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.shouldPush = nil
    }
    
    /// Create WithStapel view with evaluation function
    ///
    /// - Parameter shouldPush: An evaluation function for the root-level pusher to
    ///   decide whether to push a view or not based on supplied context
    /// - Parameter content: Views to render as children
    ///
    public init(shouldPush: @escaping PusherEvalFunc, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.shouldPush = shouldPush
    }
        
    public var body: some View {
        NavigationView {
            WithPusher(shouldPush: shouldPush) {
                content
            }
        }
        // This is crucial for natural stack behaviour
        // otherwise previous active navigation links will become inactive
        // once a new view is pushed, without getting active on pop, destroying
        // any stack logic
        // We expect pushed views to be active until popped!
        // https://developer.apple.com/documentation/swiftui/stacknavigationviewstyle
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

