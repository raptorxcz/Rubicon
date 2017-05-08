//
//  VarDeclarationType.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 22/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct VarDeclarationType {
    public var isConstant: Bool
    public var identifier: String
    public var type: Type

    public init(isConstant: Bool, identifier: String, type: Type) {
        self.isConstant = isConstant
        self.identifier = identifier
        self.type = type
    }
}
