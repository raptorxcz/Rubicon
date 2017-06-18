//
//  FunctionDeclarationType.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct FunctionDeclarationType {
    public let name: String
    public let arguments: [ArgumentType]
    public let isThrowing: Bool
    public let returnType: Type?

    public init(name: String, arguments: [ArgumentType] = [], isThrowing: Bool = false, returnType: Type? = nil) {
        self.name = name
        self.arguments = arguments
        self.isThrowing = isThrowing
        self.returnType = returnType
    }
}
