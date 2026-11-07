import XCTest

@testable import ScrapCore

final class ScpAccessPolicyTests: XCTestCase {
    private let user = ScpUser(email: "a@example.com", displayName: "A")

    func test_isAllowed_whenGuest_deniesEveryAction() {
        let policy = ScpAccessPolicy(session: .guest)

        for action in ScpAccessPolicy.Action.allCases {
            XCTAssertFalse(policy.isAllowed(action), "\(action) should be denied for guests")
        }
    }

    func test_isAllowed_whenSignedIn_allowsEveryAction() {
        let policy = ScpAccessPolicy(session: .signedIn(user))

        for action in ScpAccessPolicy.Action.allCases {
            XCTAssertTrue(policy.isAllowed(action), "\(action) should be allowed when signed in")
        }
    }

    func test_shouldPromptToCreateAccount_whenGuestTriesToSave_returnsTrue() {
        XCTAssertTrue(ScpAccessPolicy(session: .guest).shouldPromptToCreateAccount(for: .saveRecipe))
    }

    func test_shouldPromptToCreateAccount_whenSignedIn_returnsFalse() {
        XCTAssertFalse(ScpAccessPolicy(session: .signedIn(user)).shouldPromptToCreateAccount(for: .saveRecipe))
    }
}
