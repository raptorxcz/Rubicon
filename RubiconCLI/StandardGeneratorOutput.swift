//
//  StandardGeneratorOutput.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 08/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation
import Rubicon

public class StandardGeneratorOutput {}

extension StandardGeneratorOutput: GeneratorOutput {

    public func save(text: String) {
        print(text, terminator: "")
    }
}

extension StandardGeneratorOutput: ErrorGeneratorOutput {

    public func showError(text: String) {
        var errorStream = StderrOutputStream()
        print(text, to: &errorStream)
        exit(1)
    }
}

private struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}
