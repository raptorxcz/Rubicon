//
//  ProtocolType.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct ProtocolType {
    public var name: String
    public var variables: [VarDeclarationType]
    public var functions: [FunctionDeclarationType]

    public init(name: String, variables: [VarDeclarationType], functions: [FunctionDeclarationType]) {
        self.name = name
        self.variables = variables
        self.functions = functions
    }
}
