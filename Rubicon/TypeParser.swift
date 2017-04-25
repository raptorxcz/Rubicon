//
//  TypeParser.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

enum TypeParserError: Error {
    case invalidArguments
}

public class TypeParser {

    public func parse(tokens: [Token]) throws {
        throw TypeParserError.invalidArguments
    }

}
