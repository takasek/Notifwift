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
    private final class PayloadContainer {
        static let Key = "container"
        let payload: Any
        init(payload: Any) { self.payload = payload }
    }
    
    private final class ObserverContainer {
        fileprivate let name: String
        private let observer: NSObjectProtocol
        
        init(name: String, object: AnyObject?, queue: OperationQueue?, block: @escaping (_ notification:Notification) -> Void) {
            self.name = name
            self.observer = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: name),
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

    public static func post(_ name: String, from object: NSObject? = nil, payload: Any? = nil) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name),
            object: object,
            userInfo: payload.map { [PayloadContainer.Key: PayloadContainer(payload: $0)] }
        )
    }
    
    public func observe(_ name: String, from object: AnyObject? = nil, queue: OperationQueue? = nil, block: @escaping (_ notification: Notification) -> Void) {
        addToPool(name, object: object, queue: queue, block: block)
    }
    
    public func observe<T>(_ name: String, from object: AnyObject? = nil, queue: OperationQueue? = nil, block: @escaping (_ notification: Notification, _ payload: T) -> Void) {
        addToPool(name, object: object, queue: queue) { [weak self] in
            guard let payload = self?.payloadFromNotification($0) as? T else { return }
            block($0, payload)
        }
    }
    
    public func observe<T>(_ name: String, from object: AnyObject? = nil, queue: OperationQueue? = nil, block: @escaping (_ payload: T) -> Void) {
        addToPool(name, object: object, queue: queue) { [weak self] in
            guard let payload = self?.payloadFromNotification($0) as? T else { return }
            block(payload)
        }
    }
    
    public func dispose(_ name: String) {
        removeFromPool(name)
    }
    
    // MARK: private methods
    fileprivate func addToPool(_ name: String, object: AnyObject?, queue: OperationQueue?, block: @escaping (Notification) -> Void) {
        pool.append(ObserverContainer(name: name, object: object, queue: queue, block: block))
    }
    
    fileprivate func removeFromPool(_ name: String) {
        pool = pool.filter { $0.name != name }
    }
    
    fileprivate func payloadFromNotification(_ notification: Notification) -> Any? {
        return (notification.userInfo?[PayloadContainer.Key] as? PayloadContainer)?.payload
    }
    
    deinit {
        pool.removeAll()
    }
}
