import SwiftUI
import Stapel
@main
struct StapelUITestsApp: App {
    @StateObject var stack = Stack()
    
    var body: some Scene {
        WindowGroup {
            WithStapel {
                Text("Hello world!")
                StackNavigationLink(label: {
                    Text("Push")
                }, content: {
                    Text("Pushed view")
                })
            }
            .environmentObject(stack)
        }
    }
}
