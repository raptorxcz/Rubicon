@testable import Rubicon
import XCTest

final class AccessLevelGeneratorTests: XCTestCase {
    private var sut: AccessLevelGeneratorImpl!

    override func setUp() {
        super.setUp()
        sut = AccessLevelGeneratorImpl(accessLevel: .public)
    }

    func test_givenPublic_whenGenerateClassAccessLevel_thenGenerateString() {
        sut = AccessLevelGeneratorImpl(accessLevel: .public)

        let code = sut.makeClassAccessLevel()

        XCTAssertEqual(code, "public ")
    }

    func test_givenInternal_whenGenerateClassAccessLevel_thenGenerateString() {
        sut = AccessLevelGeneratorImpl(accessLevel: .internal)

        let code = sut.makeClassAccessLevel()

        XCTAssertEqual(code, "")
    }

    func test_givenPrivate_whenGenerateClassAccessLevel_thenGenerateString() {
        sut = AccessLevelGeneratorImpl(accessLevel: .private)

        let code = sut.makeClassAccessLevel()

        XCTAssertEqual(code, "private ")
    }

    func test_givenPublic_whenGenerateContentAccessLevel_thenGenerateString() {
        sut = AccessLevelGeneratorImpl(accessLevel: .public)

        let code = sut.makeContentAccessLevel()

        XCTAssertEqual(code, "public ")
    }

    func test_givenInternal_whenGenerateContentAccessLevel_thenGenerateString() {
        sut = AccessLevelGeneratorImpl(accessLevel: .internal)

        let code = sut.makeContentAccessLevel()

        XCTAssertEqual(code, "")
    }

    func test_givenPrivate_whenGenerateContentAccessLevel_thenGenerateString() {
        sut = AccessLevelGeneratorImpl(accessLevel: .private)

        let code = sut.makeContentAccessLevel()

        XCTAssertEqual(code, "")
    }
}
