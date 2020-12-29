# Stapel

A native stack navigation library for SwiftUI enabling programmatic and interactive navigation, using only NavigationLinks.

## Installation

Stapel is compatible with SwiftUI projects building for `iOS 14`  and newer.

You can install Stapel via Swift Package Manager. In Xcode, go to `File > Swift Packages > Add Package Dependency...`, and follow the instructions.

### Why Stapel?

Existing navigation libraries diverge from the navigation offered in native SwiftUI, which is understandable given the behaviour
most people are used to from NavigationLinks and managing nested navigation.

Stapel tries to create a simple layer of abstraction managing virtual stack containing views to be rendered in a nested fashion.
It does this by allowing so-called pusher views to register themselves when they appear for the first time, creating a virtual view hierarchy.
This is then used to determine where to push a new view. At the moment, it will be rendered for the view that is on top, or rather for
the pusher that was registered most recently.

### Why is Stapel not available for macOS?

As we have to use [StackNavigationStyle](https://developer.apple.com/documentation/swiftui/stacknavigationviewstyle) to be able to properly handle stack navigation, it's a requirement for Stapel to work. Unfortunately, as of now, StackNavigationStyle
is not available for macOS.

## Usage

### Setting up Stapel

Stapel exposes a Stack class that can be instantiated as StateObject, allowing SwiftUI to manage its state.
Once configured, you can pass the stack down as an environment object.

In your root view, simply use `WithStapel`, which initializes a navigation view and set the stack environment object.

```swift
import SwiftUI
import Stapel

struct ContentView: View {
    @StateObject var stack = Stack()
    
    var body: some View {
        WithStapel {
            Text("Root View")
        }
        // Pass down stack to access it anywhere, this is required!
        .environmentObject(stack)                
    }
}
```

Once the basic setup is done, you can set wrap views which should allow navigation pushes with a pusher as follows

```swift
import SwiftUI
import Stapel

struct ContentView: View {
    @StateObject var stack = Stack()
    
    var body: some View {
        WithStapel {
            StackNavigationLink(label: {
                Text("Push another view")
            }) {
                Text("Hello world!")
            }
        }
        // Pass down stack to access it anywhere, this is required!
        .environmentObject(stack)                
    }
}
```

After adding `WithStapel` to your view tree, it will automatically register a root pusher using the stack passed down as an environment object
and render pushed views assigned to it from now on. You need to add a pusher to every subsequent layer of your navigation, if you
only add it to the root view, it will simply re-render the currently pushed view if you push again.

Internally, Stapel will evaluate the list of registered pusher views and attach the view to be pushed to the pusher that is associated
with the view "on top". This results in a natural stack navigation behaviour, where new views are pushed on top.

As Stapel utilizes only native NavigationLink views under the hood, you get the benefits of having a working back button, which also
allows to pop to root, without any further configuration. You can also customize the navigation as you would do in any other app, Stapel
is merely concerned with managing your stack and deciding where a pushed view should be rendered.

### Link-based navigation

As you might have seen in the previous example, Stapel offers a low-overhead alternative to the classic
NavigationLink, rendering a Button with a given label and wiring up the pushing logic internally, to push the given
view onto the stack once a user taps on the button.

```swift
StackNavigationLink(label: {
    Text("Push another view")
}) {
    Text("Hello world!")
}
```

This is kept intentionally simple for now, but might be extended with state management functionality to trigger
a navigation link to push when a condition evaluates to true, similar to `isActive` for regular NavigationLinks. For these
types of actions, you should use programmatic navigation, though.

### Programmatic navigation

```swift
Button {
    stack.push(
        view: AnyView(
            Text("Programmatically pushed!")
        )
    )
} label: {
    Text("Tap this button to push")
}
```

This is almost a one-to-one implementation of the StackNavigationLink, which you can customize even further.
Using `stack.push`, you can push any view to the stack, whether you are in the root or leaf node of the view hierarchy.
Just push your view, and Stapel will make sure it's rendered where it should be. 

### Multiple layers (nested navigation)

Stapel handles any level of nested views just fine, don't forget to add a pusher to each level though, if you want proper
rendering of pushed views instead of resets of the current view.

```swift
import SwiftUI
import Stapel

struct ContentView: View {
    @StateObject var stack = Stack()
    
    var body: some View {
        WithStapel {
            Text("Root View")
            StackNavigationLink(label: {
                Text("Push another view")
            }) {
                WithPusher {
                    Text("Second view")
                    StackNavigationLink(label: {
                        Text("Push yet another view")
                    }) {
                        WithPusher {
                            Text("Third view")
                            StackNavigationLink(label: {
                                Text("And another view")
                            }) {
                                WithPusher {
                                    Text("Fourth view")
                                }
                            }
                        }
                    }
                }
            }
        }
        .environmentObject(stack)
    }
}
```

As you can see, you can go on and on (please split out your sub-views though).
