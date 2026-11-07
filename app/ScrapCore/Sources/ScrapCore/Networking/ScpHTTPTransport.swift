import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The one thing the Spoonacular client needs from the network: send a
/// request, get bytes back. A protocol so tests can answer without a network.
public protocol ScpHTTPTransport: Sendable {
    /// Sends `request` and returns the body and response.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
