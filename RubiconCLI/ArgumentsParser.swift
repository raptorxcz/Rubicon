//
//  ArgumentsParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 01/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public enum Arguments {
    case help
    case mocks(path: String)
}

public class ArgumentsParser {

    public init() {}

    public func parse(arguments: [String]) -> Arguments {
        if arguments.indices.contains(1), arguments[0] == "--mocks" {
            return .mocks(path: arguments[1])
        }

        return .help
    }
}
