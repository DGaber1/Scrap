import Foundation

/// The state of any screen that loads data (REQ-D-05). Every view must render
/// all five cases, so a bad response can never produce a blank screen.
public enum ScpViewState<Value> {
    /// Nothing requested yet.
    case idle
    /// A request is in flight.
    case loading
    /// The request succeeded and produced data.
    case loaded(Value)
    /// The request succeeded but there is nothing to show.
    case empty
    /// The request failed.
    case failed(ScpError)
}

extension ScpViewState: Equatable where Value: Equatable {}
extension ScpViewState: Sendable where Value: Sendable {}
