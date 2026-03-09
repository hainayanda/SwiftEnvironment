//
//  Publisher+Extensions.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import Foundation
import Combine

// MARK: - ImmediateWhenMainScheduler

/// A custom scheduler that executes immediately if already on the main thread,
/// otherwise dispatches to the main queue.
private final class ImmediateWhenMainScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions
    
    static let shared = ImmediateWhenMainScheduler()
    
    var now: SchedulerTimeType {
        DispatchQueue.main.now
    }
    
    var minimumTolerance: SchedulerTimeType.Stride {
        DispatchQueue.main.minimumTolerance
    }
    
    init() {}
    
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.schedule(options: options, action)
        }
    }
    
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
    }
}

extension Publisher where Failure == Never {
    
    func ensureOnMain() -> AnyPublisher<Output, Failure> {
        receive(on: ImmediateWhenMainScheduler.shared)
            .eraseToAnyPublisher()
    }
    
    /// Assigns the publisher's output to a property on an object using weak references to prevent retain cycles.
    /// 
    /// - Parameters:
    ///   - keyPath: The key path to the property to assign.
    ///   - object: The object whose property will be updated.
    /// - Returns: An `AnyCancellable` that can be used to cancel the subscription.
    @inlinable func weakAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable {
        sink { [weak object] output in
            object?[keyPath: keyPath] = output
        }
    }
}
