import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The real transport, backed by `URLSession`.
public struct ScpURLSessionTransport: ScpHTTPTransport {
    private let session: URLSession

    /// Creates a transport using `session` (the shared session by default).
    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}
