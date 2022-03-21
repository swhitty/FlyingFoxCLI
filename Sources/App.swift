//
//  App.swift
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
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

@main
struct App {

    static func main() async throws {
        let server = makeServer()
        try await server.start()
    }

    static func makeServer() -> HTTPServer {
        guard let path = parsePath() else {
            return HTTPServer(port: parsePort() ?? 80,
                              logger: .print(),
                              handler: makeHandler())
        }
        var addr = sockaddr_un.makeUnix(path: path)
        unlink(&addr.sun_path.0)
        return HTTPServer(address: addr,
                          logger: .print(),
                          handler: makeHandler())
    }

    static func makeHandler() -> HTTPHandler {
        var handlers = RoutedHTTPHandler()

        handlers.appendRoute("/hello?name=*") { req in
            HTTPResponse(statusCode: .ok,
                         headers: [.contentType: "text/plain; charset=UTF-8"],
                         body: "Hello \(req.query["name"]!)! 🦊".data(using: .utf8)!)
        }

        handlers.appendRoute("/hello") { _ in
            HTTPResponse(statusCode: .ok,
                         headers: [.contentType: "text/plain; charset=UTF-8"],
                         body: "Hello World! 🦊".data(using: .utf8)!)
        }

        handlers.appendRoute("/bye") { _ in
            HTTPResponse(statusCode: .ok,
                         headers: [.contentType: "text/plain; charset=UTF-8"],
                         body: "Ciao 👋".data(using: .utf8)!)
        }

        handlers.appendRoute("/jack", to: .webSocket(JackOfHeartsRecital()))

        return ClosureHTTPHandler { [handlers] in
            try await Task.sleep(nanoseconds: (200_000_000...700_000_000).randomElement()!)
            return try await handlers.handleRequest($0)
        }
    }

    static func parsePath(from args: [String] = Swift.CommandLine.arguments) -> String? {
        var last: String?
        for arg in args {
            if last == "--path" {
                return arg
            }
            last = arg
        }
        return nil
    }

    static func parsePort(from args: [String] = Swift.CommandLine.arguments) -> UInt16? {
        var last: String?
        for arg in args {
            if last == "--port" {
                return UInt16(arg)
            }
            last = arg
        }
        return nil
    }
}

struct JackOfHeartsRecital: WSMessageHandler {

    func makeMessages(for client: AsyncStream<WSMessage>) async throws -> AsyncStream<WSMessage> {
        AsyncStream<WSMessage> { continuation in
            let task = Task { await start(server: continuation, client: client) }
            continuation.onTermination = { @Sendable _ in task.cancel() }
        }
    }

    func start(server: AsyncStream<WSMessage>.Continuation, client: AsyncStream<WSMessage>) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await sendServerMessages(to: server)
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
            }
        }
    }

    func sendServerMessages(to continuation: AsyncStream<WSMessage>.Continuation) async {
        let lines = [
            "Two doors down the boys finally made it through the wall",
            "And cleaned out the bank safe, it's said they got off with quite a haul.",
            "In the darkness by the riverbed they waited on the ground",
            "For one more member who had business back in town.",
            "But they couldn't go no further without the Jack of Hearts."
        ]

        for line in lines {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            continuation.yield(.text(line))
        }
        continuation.finish()
    }
}




