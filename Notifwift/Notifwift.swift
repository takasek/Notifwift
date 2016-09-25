// The MIT License (MIT)
//
//  Copyright © 2016年 Yoshitaka Seki (takasek). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

public final class Notifwift {
    private static let payloadKey = "NotifwiftPayloadKey"

    private final class ObserverContainer {
        let name: Notification.Name
        let observer: NSObjectProtocol
        
        init(name: Notification.Name, object: Any?, queue: OperationQueue?, block: @escaping (_ notification: Notification) -> Void) {
            self.name = name
            self.observer = NotificationCenter.default.addObserver(
                forName: name,
                object: object,
                queue: queue,
                using: block
            )
        }
        
        deinit {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private var pool = [ObserverContainer]()
    
    public init() {}

    public static func post(_ name: Notification.Name, from object: Any? = nil, payload: Any? = nil) {
        NotificationCenter.default.post(
            name: name,
            object: object,
            userInfo: payload.map { [Notifwift.payloadKey: $0] }
        )
    }
    
    public func observe(_ name: Notification.Name, from object: Any? = nil, queue: OperationQueue? = nil, block: @escaping (_ notification: Notification) -> Void) {
        addToPool(name, object: object, queue: queue, block: block)
    }
    
    public func observe<T>(_ name: Notification.Name, from object: Any? = nil, queue: OperationQueue? = nil, block: @escaping (_ notification: Notification, _ payload: T) -> Void) {
        addToPool(name, object: object, queue: queue) { [weak self] in
            guard let payload: T = self?.payload(from: $0) else { return }
            block($0, payload)
        }
    }
    
    public func observe<T>(_ name: Notification.Name, from object: Any? = nil, queue: OperationQueue? = nil, block: @escaping (_ payload: T) -> Void) {
        addToPool(name, object: object, queue: queue) { [weak self] in
            guard let payload: T = self?.payload(from: $0) else { return }
            block(payload)
        }
    }
    
    public func dispose(_ name: Notification.Name) {
        removeFromPool(name)
    }
    
    // MARK: private methods
    private func addToPool(_ name: Notification.Name, object: Any?, queue: OperationQueue?, block: @escaping (Notification) -> Void) {
        pool.append(ObserverContainer(name: name, object: object, queue: queue, block: block))
    }
    
    private func removeFromPool(_ name: Notification.Name) {
        pool = pool.filter { $0.name != name }
    }
    
    private func payload<T>(from notification: Notification) -> T? {
        return notification.userInfo?[Notifwift.payloadKey] as? T
    }
    
    deinit {
        pool.removeAll()
    }
}
