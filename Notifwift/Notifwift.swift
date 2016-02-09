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
    private final class Container {
        let payload: Any
        init(payload: Any) { self.payload = payload }
    }
    private var pool = [NSObjectProtocol]()

    public init() {}

    public static func post(name: String, from object: NSObject?=nil, payload: Any?=nil) {
        NSNotificationCenter.defaultCenter().postNotificationName(name,
            object: object,
            userInfo: payload.map { ["container": Container(payload: $0)] }
        )
    }
    public func observe(name: String, from object: AnyObject?=nil, queue: NSOperationQueue?=nil, block:(notification:NSNotification) -> Void) {
        pool.append(
            NSNotificationCenter.defaultCenter().addObserverForName(name, object: object, queue: queue, usingBlock: block)
        )
    }
    public func observe<T>(name: String, from object: AnyObject?=nil, queue: NSOperationQueue?=nil, block:(notification:NSNotification, payload: T) -> Void) {
        pool.append(
            NSNotificationCenter.defaultCenter().addObserverForName(name, object: object, queue: queue) {
                guard let payload = ($0.userInfo?["container"] as? Container)?.payload as? T else { return }
                block(notification: $0, payload: payload)
            }
        )
    }
    public func observe<T>(name: String, from object: AnyObject?=nil, queue: NSOperationQueue?=nil, block:(payload: T) -> Void) {
        pool.append(
            NSNotificationCenter.defaultCenter().addObserverForName(name, object: object, queue: queue) {
                guard let payload = ($0.userInfo?["container"] as? Container)?.payload as? T else { return }
                block(payload: payload)
            }
        )
    }
    deinit {
        pool.forEach { NSNotificationCenter.defaultCenter().removeObserver($0) }
    }
}