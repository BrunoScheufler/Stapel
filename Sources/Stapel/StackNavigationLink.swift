import SwiftUI

/// Similar to the native NavigationLink, StackNavigationLink renders a button that will push
/// a specified view on tap.
///
///     StackNavigationLink(label: {
///       Text("Push")
///     }) {
///       Text("View to render")
///     }
public struct StackNavigationLink<Label: View, Content: View>: View {
    let label: Label
    let content: Content
    
    public init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.label = label()
    }
    
    @EnvironmentObject var stack: Stack
    
    public var body: some View {
        Button(
            action: {
                stack.push(view: AnyView(content))
            },
            label: {
                label
            }
        )
    }
}

/// Render navigation button with additional styling like an right-facing arrow for list elements.
///
/// - Important: This only works for list children, not as standalone components.
///   You should use `StackNavigationLink` for rendering a regular button
public struct ListNavigationLink<Label: View, Content: View>: View {
    let label: Label
    let content: Content
    
    /// This only works for list children, not as standalone components
    /// You should use StackNavigationLink for rendering a regular button
    public init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.label = label()
    }
    
    public var body: some View {
        // Nest native NavigationLink in Button
        // to get benefits of styling while also
        // having interactivity with regular button
        StackNavigationLink(label: {
            NavigationLink(
                destination: EmptyView(),
                isActive: .constant(false),
                label: {
                    label
                })
        }, content: { content })
    }
}
