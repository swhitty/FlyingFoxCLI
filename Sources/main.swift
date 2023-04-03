//
//  main.swift
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
import FlyingSocks
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(WinSDK)
import WinSDK.WinSock2
#endif

func makeServer(from args: [String] = Swift.CommandLine.arguments) -> HTTPServer {
    guard let path = parsePath(from: args) else {
        return HTTPServer(port: parsePort(from: args) ?? 80,
                          logger: .print())
    }
    var addr = sockaddr_un.unix(path: path)
    unlink(&addr.sun_path.0)
    return HTTPServer(address: addr,
                      logger: .print())
}

func parsePath(from args: [String]) -> String? {
    var last: String?
    for arg in args {
        if last == "--path" {
            return arg
        }
        last = arg
    }
    return nil
}

func parsePort(from args: [String]) -> UInt16? {
    var last: String?
    for arg in args {
        if last == "--port" {
            return UInt16(arg)
        }
        last = arg
    }
    return nil
}

let server = makeServer()

await server.appendRoute("/hello?name=*") { req in
    HTTPResponse(statusCode: .ok,
                 headers: [.contentType: "text/plain; charset=UTF-8"],
                 body: "Hello \(req.query["name"]!)! 🦊".data(using: .utf8)!)
}

await server.appendRoute("/size") { req in
    var size: Int = 0
    for try await chunk in req.bodySequence {
        size += chunk.count
    }
    return HTTPResponse(statusCode: .ok,
                 headers: [.contentType: "text/plain; charset=UTF-8"],
                 body: "Size: \(size) bytes".data(using: .utf8)!)
}

await server.appendRoute("/hello") { _ in
    HTTPResponse(statusCode: .ok,
                 headers: [.contentType: "text/plain; charset=UTF-8"],
                 body: "Hello World! 🦊".data(using: .utf8)!)
}

await server.appendRoute("/bye") { _ in
    HTTPResponse(statusCode: .ok,
                 headers: [.contentType: "text/plain; charset=UTF-8"],
                 body: "Ciao 👋".data(using: .utf8)!)
}

await server.appendRoute("/jack", to: .webSocket(JackOfHeartsRecital()))

try await server.start()
