//
//  FunctionDeclarationType.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct FunctionDeclarationType {
    public var name: String
    public var arguments: [ArgumentType]

    public init(name: String, arguments: [ArgumentType]) {
        self.name = name
        self.arguments = arguments
    }
}
