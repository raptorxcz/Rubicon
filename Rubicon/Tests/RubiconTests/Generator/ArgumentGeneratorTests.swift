@testable import Rubicon
import XCTest

final class ArgumentGeneratorTests: XCTestCase {
    private var typeGeneratorSpy: TypeGeneratorSpy!
    private var sut: ArgumentGeneratorImpl!

    override func setUp() {
        super.setUp()
        typeGeneratorSpy = TypeGeneratorSpy(makeVariableCodeReturn: "", makeArgumentCodeReturn: "Type")
        sut = ArgumentGeneratorImpl(
            typeGenerator: typeGeneratorSpy
        )
    }

    func test_givenTypeWithoutLabel_whenMakeCode_thenReturnCode() {
        let declaration = ArgumentDeclaration.makeStub(label: nil)

        let code = sut.makeCode(from: declaration)

        XCTAssertEqual(code, "name: Type")

    }

    func test_givenTypeWithLabel_whenMakeCode_thenReturnCode() {
        let declaration = ArgumentDeclaration.makeStub()

        let code = sut.makeCode(from: declaration)

        XCTAssertEqual(code, "label name: Type")
    }
}
