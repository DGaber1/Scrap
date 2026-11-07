import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@testable import ScrapCore

/// A transport that answers every request with a fixed status and body, and
/// remembers the last URL it was asked for.
final class StubScpHTTPTransport: ScpHTTPTransport, @unchecked Sendable {
    let statusCode: Int
    let body: Data
    let shouldThrow: Bool
    private(set) var requestedURLs: [URL] = []

    init(statusCode: Int = 200, json: String = "[]", shouldThrow: Bool = false) {
        self.statusCode = statusCode
        self.body = Data(json.utf8)
        self.shouldThrow = shouldThrow
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        let url = request.url ?? URL(fileURLWithPath: "/")
        requestedURLs.append(url)
        guard let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil) else {
            throw URLError(.badServerResponse)
        }
        return (body, response)
    }
}
