//
//  StandardGeneratorOutput.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 06/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation

public protocol GeneratorOutput {

    func save(text: String)
    
}

public protocol ErrorGeneratorOutput {

    func showError(text: String)

}

class StandardGeneratorOutput {}

extension StandardGeneratorOutput: GeneratorOutput {

    func save(text: String) {
        print(text)
    }

}

extension StandardGeneratorOutput: ErrorGeneratorOutput {

    func showError(text: String) {
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
