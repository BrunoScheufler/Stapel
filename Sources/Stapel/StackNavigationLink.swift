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
