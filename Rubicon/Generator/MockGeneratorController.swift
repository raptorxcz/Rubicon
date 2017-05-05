//
//  MockGeneratorController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public protocol MocksGeneratorController {
    func run(text: String)
}

public protocol GeneratorOutput {

    func save(text: String)

}

public class MocksGeneratorControllerImpl {

    fileprivate let output: GeneratorOutput

    public init(output: GeneratorOutput) {
        self.output = output
    }

}

extension MocksGeneratorControllerImpl: MocksGeneratorController {

    public func run(text: String) {
        output.save(text: "")
    }

}
