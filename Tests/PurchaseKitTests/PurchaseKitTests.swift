import XCTest
@testable import PurchaseKit

final class PurchaseKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PurchaseKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
