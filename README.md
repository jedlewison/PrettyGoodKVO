# PrettyGoodKVO

PrettyGoodKVO is an experimental framework for Cocoa key-value observing that delivers:

1. Automatic unobservation when observed objects deallocate
2. Strong-typing in Swift -- you get the old and new values as Swift types, not `AnyObject?`s.
3. Handle changes in closures that only fire with initial values and subsequent changes.

PrettyGoodKVO requires iOS 9.0. If you want to test/validate it on iOS 8.0, PRs are welcome. It should work on OS X 10.11, but hasn't been tested.

## Installing

PrettyGoodKVO has a Podspec and will be in CocoaPods soon. It's Carthage compatible.

## Usage

### Swift

#### Observing

Generally, you'll want to use the `PGKVOObserving` to handle observation in Swift. `PGKVOObserving` manages type safety and filters change observations so that you only see actual changes. The default implementation handles all the work -- you can use it as follows:

```swift
extension SomeClass: PGKVOObserving {

    func observeSomeStuff(thing: AnObservableNSObject) {
        observe(thing, keyPath: "awesomeProperty", intialValue: thing.awesomeProperty) {
            change in
            switch change.new {
            case .Idle:
                assert(change.kind == .Initial, "We should only be idle at the beginning.")
            case .Started:
                assert(change.old == .Idle, "We should only start once.")
            case .Progress where change.old == .Started:
                // Our first progress
            case .Progress:
                // We're continuing
            case .Finished:
                change.unobserveAllKeyPaths()
            }
        }
    }
```

**Note:**
* SomeClass must be a class, but it can be a pure Swift class -- it doesn't need to be an `NSObject`.
* You can specificy a queue for the results by adding a value for the `resultsQueue` property (for example, `.mainQueue()`).
* Although we can unobserve within the changes block, we don't need to -- the observed object can deallocate and we will stop observing automatically.
* The awesomeProperty enum needs to be an @objc enum to work with KVO. For PrettyGoodKVO to parse it, simply add conformance to `PGKVOChangeValueConvertible`. The default implementation will do the work.

#### Unobserving

```swift
import PrettyGoodKVO

extension SomeClass: PGKVOObserving {

    func cancelAwesomeSauce(something: AnObservableNSObject) {
        // We don't actually have to cancel observation to avoid retain cycle,
        // but we don't want to receive any further notifications before it deallocates
        unobserveAllKeyPaths(ofObject: something)
    }

}
```

Unobserving is simple -- just call `unobserveAllKeyPaths(ofObject: NSObject)` or `unobserve(object: NSObject, keyPath: String?)` and you will stop receiving observation notifications for the object. You can unobserve at any time, inside or outside the change callback.

Keep in mind that you don't actually need to unobserve unless you want to stop getting notifications. It's generally a good idea to stop observing once you no longer need anything if both you and the object will stay alive, but if you're both about to deallocate, you can just let PrettyGoodKVO take care of the details.

### Objective-C

#### Observing

```Objective-C
@import PrettyGoodKVO;

...

[self pgkvo_observe:self.somethingAwesome
         forKeyPath:keypath(self.somethingAwesome, awesomeProperty)
            options:NSKeyValueObservingOptionNew
            closure:^(typeof(self) _Nonnull observer,
                    typeof(self.somethingAwesome) _Nonnull observed,
                    NSDictionary<NSString *,id> * _Nullable changes) {
                if (observed.awesomeProperty == 99) {
                    [observer doSomethingAwesomeNow];
                }
            }];
```

** Note:**

* Objective-C can't do type-safety like Swift, unfortunately, but everything else about automatic unobservation applies.
* You may want to use this from Swift if you're observing Foundation collection types or want finer control over options and/or changes.
* If you haven't already seen it, the keypath macro used here is awesome. It's by @robrix. [Source](https://twitter.com/rob_rix/status/437061333356666880)

#### Unobserving

```Objective-C
[self pgkvo_unobserve:self.somethingAwesome
           forKeyPath:keypath(self.somethingAwesome, awesomeProperty)];

```

### PGKVOChangeValueConvertible

PrettyGoodKVO transforms NSValues into native Swift structs using the `PGKVOChangeValueConvertible` protocol. If you're having trouble transforming an NSValue to a native Swift struct, you'll probably need to implement that protocol on the type in question. If it's an Objective-C enum, simply add the `PGKVOChangeValueConvertible` conformance and you will automatically get the type you're looking because there is a default implementation for `RawRepresentable`.

### How the magic stuff works (iow, the scary part)

Out of the box, KVO requires you to remove observers from objects they are observing before the observed objects deallocate. This requires error-prone bookkeeping which in turn often requires keeping observed objects alive longer than they are actually needed, wasting resources.

PrettyGoodKVO aims to solve this by attaching a proxy observer to the object under observation using `obj_setAssociatedObject`. When the observed object deallocates, this causes the proxy to deallocate as well because the proxy does not have a strong reference to the observed object. Unfortunately, the proxy's weak reference to the observed object becomes nil before it deallocates. This is a problem because the proxy still must remove itself as an observer before the observed object finishes deallocating or an NSException will be thrown, crashing the app. Fortunately, it's possible to store an unsafe unowned reference to the observed object in an instance of NSValue. When the proxy deallocates, that reference to the observed object is still valid, giving us a chance to remove the proxy as an observer and preventing the crash.

If this sounds a bit scary, you're not alone. Based on a fair amount of testing, it works, but I'm not 100% sure it will continue to work in the future. I'm probably going to file a DTS to see if I can find out, because it would be great if this is reliable behavior.

### How everything else works

Other than that, there really isn't any magic to PrettyGoodKVO -- just some synchronization for thread safety, protocols to enable type safety on Swift, and some code to help the `PGKVOProxy` keep track of what it's doing.