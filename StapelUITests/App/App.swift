import SwiftUI
import Stapel


struct StapelSimpleScenario: View {
    var body: some View {
        WithStapel {
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
}

struct StapelNestedScenario: View {
    var body: some View {
        WithStapel {
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
}

struct StapelContextBasedScenario: View {
    @EnvironmentObject var stack: Stack
    var body: some View {
        WithStapel({ (context) -> Bool in
            guard let hasExpected = context["expected"] else {
                return false
            }
            guard let isString = hasExpected as? String else {
                return false
            }
            return isString == "value"
        }) {
            Text("Root view")
            Button(action: {
                stack.push(view: AnyView(Text("No-op")))
            }, label: {
                Text("Push falsy")
            })
            Button(action: {
                stack.push(view: AnyView(Text("Pushed with evaluation")), context: ["expected" : "value"])
            }, label: {
                Text("Push truthy")
            })
        }
    }
}

struct StapelWithoutVStackScenario: View {
    var body: some View {
        WithStapel {
            Text("Should be visible")
            Text("This too")
        }
    }
}

@main
struct StapelUITestsApp: App {
    @StateObject var stack = Stack()
    
    func renderBody () -> AnyView {
        switch ProcessInfo.processInfo.environment["test_scenario"] {
        case "evaluate":
            return AnyView(StapelContextBasedScenario())
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
            renderBody()
                .environmentObject(stack)
        }
    }
}
