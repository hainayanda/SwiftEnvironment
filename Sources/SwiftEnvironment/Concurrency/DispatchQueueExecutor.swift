//
//  DispatchQueueExecutor.swift
//  SwiftEnvironment
//

import Foundation

final class DispatchQueueExecutor: @unchecked Sendable {
    private let queue: DispatchQueue
    private let specificKey = DispatchSpecificKey<Void>()

    init(_ queue: DispatchQueue) {
        self.queue = queue
        queue.setSpecific(key: specificKey, value: ())
    }

    func sync<Result>(
        flags: DispatchWorkItemFlags = [],
        execute work: () throws -> Result
    ) rethrows -> Result {
        if DispatchQueue.getSpecific(key: specificKey) != nil {
            return try work()
        }
        return try queue.sync(flags: flags, execute: work)
    }
}
