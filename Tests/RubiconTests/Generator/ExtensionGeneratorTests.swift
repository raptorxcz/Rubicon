@testable import Rubicon
import XCTest

final class ExtensionGeneratorTests: XCTestCase {
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var indentationGeneratorStub: IndentationGeneratorStub!
    private var sut: ExtensionGeneratorImpl!

    override func setUp() {
        super.setUp()
        accessLevelGeneratorSpy = AccessLevelGeneratorSpy(makeClassAccessLevelReturn: "accessLevel ", makeContentAccessLevelReturn: "")
        indentationGeneratorStub = IndentationGeneratorStub()
        sut = ExtensionGeneratorImpl(
            accessLevelGenerator: accessLevelGeneratorSpy,
            indentationGenerator: indentationGeneratorStub
        )
    }

    func test_whenGenerate_thenGenerateCode() {
        let code = sut.make(name: "String", content: ["content", "content2"])

        equal(code, rows: [
            "accessLevel extension String {",
            "-content",
            "-content2",
            "}",
        ])
        XCTAssertEqual(accessLevelGeneratorSpy.makeClassAccessLevelCount, 1)
    }
}
