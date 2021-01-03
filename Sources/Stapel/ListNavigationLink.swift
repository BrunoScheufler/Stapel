import SwiftUI

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
