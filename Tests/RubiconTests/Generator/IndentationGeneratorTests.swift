@testable import Rubicon
import XCTest

final class IndentationGeneratorTests: XCTestCase {
    private var sut: IndentationGeneratorImpl!

    override func setUp() {
        super.setUp()
        sut = IndentationGeneratorImpl(indentStep: "-")
    }

    func test_givenSomeString_whenIndenting_thenIndent() {
        let result = sut.indenting("a")

        XCTAssertEqual(result, "-a")
    }

    func test_givenEmptyString_whenIndenting_thenNotIndent() {
        let result = sut.indenting("")

        XCTAssertEqual(result, "")
    }
}
