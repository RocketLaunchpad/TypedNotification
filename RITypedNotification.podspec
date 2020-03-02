# vi: ft=ruby

Pod::Spec.new do |s|
  s.name = "RITypedNotification"
  s.module_name = "TypedNotification"
  s.version = "1.1.0"
  s.summary = "RITypedNotification Library"

  s.description = <<-DESC
# TypedNotification

The `TypedNotification` microframework allows you to use `NotificationCenter` to post and receive strongly-typed notifications with associated data, without having to manually pack and unpack a `userInfo` dictionary.

Using a typed notification is simple. First, define a notification type:

```
struct MyNotification: TypedNotification {
    var value: String
}
```

Next, use `NotificationCenter` to add an observer for that notification:

```
class MyViewController: UIViewController {
    private var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        token = NotificationCenter.default.addObserver(for: MyNotification.self) { [weak self] (notification) in
            self?.received(notification)
        }
    }

    private func received(_ notification: MyNotification) {
        print(notification.value)
    }
}
```

In the example, `MyViewController` retains the `NotificationToken` returned by `NotificationCenter.addObserver()`. When the `MyViewController` instance is deallocated, the `NotificationToken` is deallocated and the observer is deregistered. **The `[weak self]` capture list is important. Without it, there _will_ be a retain cycle causing a memory leak.**

Finally, use `NotificationCenter` to post notifications:

```
NotificationCenter.default.post(MyNotification(value: "foobar"), from: self)
```
  DESC

  s.homepage = "https://www.rocketinsights.com"

  s.author = "Paul Calnan"

  s.source = { :git => "https://github.com/rocketinsights/RITypedNotification.git", :tag => "#{s.version}" }
  s.license = { :type => "MIT" }

  s.platform = :ios, "11.0"
  s.swift_version = "5.0"

  s.source_files = "Sources/TypedNotification/**/*.swift"
end

