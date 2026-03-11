import XCTest
@testable import gather

final class gatherTests: XCTestCase {
    func testHeaderAdjustment() throws {
        let gather = Gather()
        let input = """
# Header 1
Some text
## Header 2
More text
"""
        let expected = """
### Header 1
Some text
#### Header 2
More text
"""
        let result = gather.adjustHeaderLevels(in: input, by: 2)
        XCTAssertEqual(result, expected)
    }

    func testHeaderAdjustmentNoHeaders() throws {
        let gather = Gather()
        let input = "Just some text without headers"
        let result = gather.adjustHeaderLevels(in: input, by: 2)
        XCTAssertEqual(result, input)
    }
}
