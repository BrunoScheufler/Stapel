import SwiftUI
import Stapel


struct StapelSimpleScenario: View {
    var body: some View {
        VStack {
            Text("Hello world!")
            StackNavigationLink(label: {
                Text("Push")
            }, content: {
                Text("Pushed view")
            })
        }
    }
}

struct StapelNestedScenario: View {
    var body: some View {
        VStack {
            Text("Root View").navigationBarTitle("Root view")
            StackNavigationLink(label: {
                Text("Push another view")
            }) {
                WithPusher {
                    Text("Second view").navigationBarTitle("Second view")
                    StackNavigationLink(label: {
                        Text("Push yet another view")
                    }) {
                        WithPusher {
                            Text("Third view").navigationBarTitle("Third view")
                            StackNavigationLink(label: {
                                Text("And another view")
                            }) {
                                WithPusher {
                                    Text("Fourth view").navigationBarTitle("Fourth view")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct StapelWithoutVStackScenario: View {
    var body: some View {
        Text("Should be visible")
        Text("This too")
    }
}

@main
struct StapelUITestsApp: App {
    @StateObject var stack = Stack()
    
    func renderBody () -> AnyView {
        switch ProcessInfo.processInfo.environment["test_scenario"] {
        case "nested":
            return AnyView(StapelNestedScenario())
        case "without_vstack":
            return AnyView(StapelWithoutVStackScenario())
        case "simple":
            fallthrough
        default:
            return AnyView(StapelSimpleScenario())
        }
    }
    
    var body: some Scene {
        WindowGroup {
            WithStapel {
                renderBody()
            }
            .environmentObject(stack)
        }
    }
}
