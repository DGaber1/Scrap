import XCTest

@testable import ScrapCore

final class ScpViewStateTests: XCTestCase {
    func test_equality_comparesCasesAndPayloads() {
        XCTAssertEqual(ScpViewState<Int>.loaded(3), .loaded(3))
        XCTAssertNotEqual(ScpViewState<Int>.loaded(3), .loaded(4))
        XCTAssertEqual(ScpViewState<Int>.failed(.network), .failed(.network))
        XCTAssertNotEqual(ScpViewState<Int>.idle, .loading)
    }
}
