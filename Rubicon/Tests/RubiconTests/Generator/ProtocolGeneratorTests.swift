@testable import Rubicon
import XCTest

final class ProtocolGeneratorTests: XCTestCase {
    private var accessLevelGeneratorSpy: AccessLevelGeneratorSpy!
    private var sut: ProtocolGeneratorImpl!

    override func setUp() {
        super.setUp()
        accessLevelGeneratorSpy = AccessLevelGeneratorSpy(makeClassAccessLevelReturn: "accessLevel ", makeContentAccessLevelReturn: "")
        sut = ProtocolGeneratorImpl(accessLevelGenerator: accessLevelGeneratorSpy)
    }

    func test_whenGenerate_thenGenerateCode() {
        let code = sut.makeProtocol(from: .makeStub(), stub: "Dummy", content: "content")

        equal(string: code, rows: [
            "accessLevel final class NameDummy: Name {",
            "content",
            "}",
            "",
        ])
        XCTAssertEqual(accessLevelGeneratorSpy.makeClassAccessLevelCount, 1)
    }
}

func equal(string: String, rows: [String], line: UInt = #line, file: StaticString = #file) {
    let generatedRows = string.components(separatedBy: "\n")

    XCTAssertEqual(generatedRows.count, rows.count, file: file, line: line)
    var index: UInt = 1

    for (line1, line2) in zip(generatedRows, rows) {
        XCTAssertEqual(line1, line2, file: file, line: line + index)
        index += 1
    }
}

final class AccessLevelGeneratorSpy: AccessLevelGenerator {
    var makeClassAccessLevelCount = 0
    var makeClassAccessLevelReturn: String
    var makeContentAccessLevelCount = 0
    var makeContentAccessLevelReturn: String

    init(makeClassAccessLevelReturn: String, makeContentAccessLevelReturn: String) {
        self.makeClassAccessLevelReturn = makeClassAccessLevelReturn
        self.makeContentAccessLevelReturn = makeContentAccessLevelReturn
    }

    func makeClassAccessLevel() -> String {
        makeClassAccessLevelCount += 1
        return makeClassAccessLevelReturn
    }

    func makeContentAccessLevel() -> String {
        makeContentAccessLevelCount += 1
        return makeContentAccessLevelReturn
    }
}
