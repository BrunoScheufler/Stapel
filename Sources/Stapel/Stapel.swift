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
    let content: Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
        
    public var body: some View {
        NavigationView {
            WithPusher {
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

