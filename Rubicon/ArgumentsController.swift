//
//  ArgumentsController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 01/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class ArgumentsController {

    private let fileReader: FileReader
    private let helpController: HelpController
    private let mocksController: MocksGeneratorController

    public init(fileReader: FileReader, helpController: HelpController, mocksController: MocksGeneratorController) {
        self.fileReader = fileReader
        self.helpController = helpController
        self.mocksController = mocksController
    }

    public func run(arguments: [String]) {
        guard arguments.indices.contains(2) else {
            helpController.run()
            return
        }

        let result = fileReader.readFiles(at: arguments[2])
        mocksController.run(texts: result)
    }

}
