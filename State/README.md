# State.swift

>__Warning__: This is a toy project. ___Please don't use this in your apps___. If you need a signal/observer library, there are much better, safer, more thorough and well-tested options out there. This implementation was deliberately as minimal as possible.

`State` is a type that wraps a `Binding` and tracks its ongoing value changes. Its interface is meant to mimic SwiftUI's `@State` and `@Binding` usage, without actually requiring iOS 13 or Swift 5.1.

```swift
class ViewController: UIViewController {
    let userInput = State(initialValue: "")
    
    override func viewDidLoad() {
        let bindingView = YourCustomView(updating: userInput.binding)
        // `userInput` is updated automatically whenever `bindingView` posts to the binding
    }
    
    func onDoneButtonPressed() {
        validate(userInput.snapshot)
    }
}
```

#### Why did I do this

For fun.

I already had the `Binding` code lying around from previously playing with a custom model-view binding system. Since SwiftUI's debut, I thought I'd try adopting its patterns to UIKit just to see how close I could get.

Again, this implementation is intentionally minimal. Initially, I was simply trying to understand and demystify signal patterns to myself by making my own with as little code as possible. So there's not even any way to un-register an observer, for example, as it's just a closure stored in an array. Instead, it relies on objects eventually nulling out and the closure becoming a no-op. This is obviously unsafe.

#### Why did I share this

When I initially looked for examples of minimal signal implementations in Swift I came up empty handed. So at the very least this can serve as a reference for anyone else seeking to understand signal patterns, albeit as a _starting point_. The complexities added by more robust implementations are very necessary for their safety and practical application. I certainly make no claims to this being an accurate portrayal of a real-world signal type.

I also may eventually share my custom view code that use `Binding`s to self-manage, SwiftUI-style. Again, not for use as a proper library for anyone's app code to depend on. Just for fun. Because I enjoy playing around with this kind of stuff.
