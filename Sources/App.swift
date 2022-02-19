import FlyingFox

@main
struct App {

    static func main() async throws {
        let server = HTTPServer(port: parsePort() ?? 80, logger: .print())
        await server.appendHandler(for: "*", closure: Self.helloWorld)
        try await server.start()
    }

    @Sendable
    static func helloWorld(_ request: HTTPRequest) async throws -> HTTPResponse {
        return HTTPResponse(statusCode: .ok,
                            headers: [.contentType: "text/plain"],
                            body: "Hello World!".data(using: .utf8)!)
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
