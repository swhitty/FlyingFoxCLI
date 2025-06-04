//
//  JackOfHeartsRecital.swift
//  FlyingFoxCLI
//
//  Created by Simon Whitty on 19/02/2022.
//  Copyright © 2022 Simon Whitty. All rights reserved.
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/swhitty/FlyingFoxCLI
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import FlyingFox
import Foundation

struct JackOfHeartsRecital: WSMessageHandler {

    func makeMessages(for client: AsyncStream<WSMessage>) async throws -> AsyncStream<WSMessage> {
        AsyncStream<WSMessage> { continuation in
            let task = Task { await start(sendingTo: continuation, client: client) }
            continuation.onTermination = { @Sendable _ in task.cancel() }
        }
    }

    func start(sendingTo continuation: AsyncStream<WSMessage>.Continuation, client: AsyncStream<WSMessage>) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await sendMessages(to: continuation)
            }
            group.addTask {
                await logClientMessages(from: client)
            }
            await group.waitForAll()
        }
    }

    func logClientMessages(from messages: AsyncStream<WSMessage>) async {
        for await message in messages {
            switch message {
            case .text(let message):
                print("received string:", message)
            case .data(let data):
                print("received data:", data.count, "bytes")
            case .close(let code):
                print("close with code: \(code.code), reason: \(code.reason)")
            }
        }
    }

    func sendMessages(to continuation: AsyncStream<WSMessage>.Continuation) async {
        do {
            let url = Bundle.html.url(forResource: "jack.txt", withExtension: nil)!
            let lines = try String(contentsOf: url, encoding: .utf8)
                .split(separator: "\n")

            for line in lines {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                continuation.yield(.text(String(line)))
            }
            continuation.finish()
        } catch {
            print("error: \(error)")
            continuation.finish()
        }
    }
}
