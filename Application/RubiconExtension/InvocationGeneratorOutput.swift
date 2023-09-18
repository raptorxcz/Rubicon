import Foundation
import Rubicon
import XcodeKit

class InvocationGeneratorOutput: GeneratorOutput {
    private let invocation: XCSourceEditorCommandInvocation

    init(invocation: XCSourceEditorCommandInvocation) {
        self.invocation = invocation
    }

    func save(lines: [String]) {
        invocation.buffer.lines.addObjects(from: lines)
    }
}
