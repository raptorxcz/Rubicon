@testable import Rubicon
import XCTest

final class TypGeneratorTests: XCTestCase {
    private var sut: TypeGeneratorImpl!

    override func setUp() {
        super.setUp()
        sut = TypeGeneratorImpl()
    }

    func test_whenGenerate_thenGenerateCode() {
        let typeDeclaration = TypeDeclaration.makeStub()

        let code = sut.makeVariableCode(from: typeDeclaration)

        XCTAssertEqual(code, "Int")
    }

    func test_givenClosure_whenGenerate_thenGenerateCode() {
        let typeDeclaration = TypeDeclaration.makeStub(name: "() -> Void", prefix: [.escaping])

        let code = sut.makeVariableCode(from: typeDeclaration)

        XCTAssertEqual(code, "() -> Void")
    }

    func test_givenOptional_whenGenerate_thenGenerateCode() {
        let typeDeclaration = TypeDeclaration.makeStub(name: "() -> Void?", isOptional: true)

        let code = sut.makeVariableCode(from: typeDeclaration)

        XCTAssertEqual(code, "() -> Void?")
    }

}
