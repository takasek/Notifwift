# Notifwift

[![Version](https://img.shields.io/cocoapods/v/Notifwift.svg?style=flat)](http://cocoapods.org/pods/Notifwift)
[![License](https://img.shields.io/cocoapods/l/Notifwift.svg?style=flat)](http://cocoapods.org/pods/Notifwift)
[![Platform](https://img.shields.io/cocoapods/p/Notifwift.svg?style=flat)](http://cocoapods.org/pods/Notifwift)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Notifwift is the NS**Notif**icationCenter wrapper for S**wift**.

Notifwift resolves;

- cumbersome management of Notification observers
- meaningless dictionary key required for Notification.userInfo
- long syntax to post/observe notifications


## Usage

```swift
    let notificationName = Notification.Name(rawValue: "YourNotificationName")
    do {
        let notifwift = Notifwift()
        notifwift.observe(notificationName) {(notification) in
            print("Notifwift can observe Notification in simple way.", notification)
        }
        Notifwift.post(notificationName)
        //printed:
        // Notifwift can observe Notification in simple way. name = YourNotificationName, object = nil, userInfo = nil
    }
    
    Notifwift.post(notificationName)
    //printed nothing. Observers expire when the Notifwift instance(in this case) is destructed.
```

```swift
    let notifwift = Notifwift()
    notifwift.observe(notificationName) { (payload: String) in
        print("This closure observes nothing but Notification with String payload.", payload)
    }
    notifwift.observe(notificationName) { (payload: Int) in
        print("This closure observes nothing but Notification with Int payload.", payload)
    }
    
    Notifwift.post(notificationName, payload:"aaaa")
    //printed:
    // This closure observes nothing but Notification with String payload. aaaa
    
    Notifwift.post(notificationName, payload:1)
    //printed:
    // This closure observes nothing but Notification with Int payload. 1
```

The receiver block accepts:

- `(Notification) -> Void`
- `(Notification, T) -> Void`
- `(T) -> Void`

```swift
    class Animal {}
    class Cat: Animal {}
    
    let notifwift = Notifwift()
    notifwift.observe(notificationName) { (_, p:Animal) in
        print("Received Animal.", p)
    }
    notifwift.observe(notificationName) { (_, p:Cat) in
        print("Received Cat. Yes, of course, Notifwift recognizes subtypes.", p)
    }
    
    Notifwift.post(notificationName, payload:Animal())
    //printed:
    // Received Animal. (Animal #1)
    
    Notifwift.post(notificationName, payload:Cat())
    //printed:
    // Received Animal. (Cat #1)
    // Received Cat. Yes, of course, Notifwift recognizes subtypes. (Cat #1)
```

```swift
    enum SomeResult {
        case Success(String)
        case Fail(NSError)
    }
    let notifwift = Notifwift()
    notifwift.observe(notificationName) { (_, p:SomeResult) in
        switch p {
        case .Success(let str):
            print("Any Type can be used as a payload", str)
        case .Fail(let err) where err.code == 403:
            print("not authorized")
        case .Fail(let err) where err.code == 404:
            print("not found")
        case .Fail(let err):
            print("Notifwift has a chemistry with Enum Associated Values.", err)
        }
    }
    
    Notifwift.post(notificationName, payload:SomeResult.Success("like this."))
    //printed:
    // Any Type can be used as a payload like this.

    Notifwift.post(notificationName, payload:SomeResult.Fail(NSError(domain: "", code: 0, userInfo: nil)))
    //printed:
    // Notifwift has a chemistry with Enum Associated Values. Error Domain= Code=0 "(null)"
```

```swift
    let obj1 = NSObject()
    let obj2 = NSObject()
    let notifwift = Notifwift()
    notifwift.observe(notificationName) { _ in
        print("Received from all objects")
    }
    notifwift.observe(notificationName, from: obj1) { _ in
        print("Received from obj1 only")
    }
    notifwift.observe(notificationName, from: obj2) { _ in
        print("Received from obj2 only")
    }
    
    Notifwift.post(notificationName, from: obj1)
    //printed:
    // Received from all objects
    // Received from obj1 only
    
    Notifwift.post(notificationName, from: obj2)
    //printed:
    // Received from all objects
    // Received from obj2 only
```

Since the registered observers for notifications are to disposed automatically when the Notifwift instance is dead, you can dispose them by your self.

```
    notifwift.dispose(dispose)
```


## Real World Example

Here's an example usage.

```swift
let didReceiveUserNotification = Notification.Name(rawValue: "didReceiveUserNotification")

final class MyViewController: UIViewController {
    @IBOutlet var userInfoView: MyUserInfoView!
    let notifwift = Notifwift()

    override func viewDidLoad() {
        super.viewDidLoad()
        notifwift.observe(didReceiveUserNotification) { [unowned self] in self.reload($0) } //Use `weak` or `unowned` on calling the self methods to avoid retain cycles.
    }
    
    private func reload(user: User) {
        userInfoView.reload(user)
    }
}

final class MyUserRepository {
    func fetchUser(id: Int) {
        MyAPIManager.fetchUser(id) { (user: User) in
            Notifwift.post(didReceiveUserNotification, payload: user)
        }
    }
}

```

The Notifwift instance is alive during MyViewController instance.
It dies when MyViewController instance dies, so observers registered in the Notifwift instance are to be removed automatically.  Never mind if you have to manage observer!

## Installation

Notifwift is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Notifwift"
```

Notifwift is available through [Carthage](https://github.com/Carthage/Carthage). To install it, simply add the following line to your Cartfile:
 
```ruby
github "takasek/Notifwift"
```

## Author

[takasek](https://twitter.com/takasek)

## License

Notifwift is available under the MIT license. See the LICENSE file for more info.
