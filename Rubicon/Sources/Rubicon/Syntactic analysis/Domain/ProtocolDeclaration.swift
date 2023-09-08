//
//  ProtocolDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct ProtocolDeclaration {
    public var name: String
    public var parents: [String]
    public var variables: [VarDeclaration]
    public var functions: [FunctionDeclaration]

    public init(name: String, parents: [String], variables: [VarDeclaration], functions: [FunctionDeclaration]) {
        self.name = name
        self.parents = parents
        self.variables = variables
        self.functions = functions
    }
}
