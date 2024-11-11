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
import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(WinSDK)
import WinSDK.WinSock2
#endif

let address: any SocketAddress = .loopback(port: 5000)
let socket = try Socket(domain: Int32(type(of: address).family), type: Int32(SOCK_DGRAM))
try socket.bind(to: address)

let server = try await AsyncSocket(socket: socket, pool: .client)

repeat {
    let (client, bytes) = try await server.receive(atMost: 100)
    let message = String(data: Data(bytes), encoding: .utf8) ?? "<not utf8>"
    print("receive", client, message)
    try await server.send("received: \(bytes.count)\n".data(using: .utf8)!, to: client.makeSocketAddress())
} while true

