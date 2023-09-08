//
//  VarDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 22/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct VarDeclaration {
    public var prefix: String?
    public var isConstant: Bool
    public var identifier: String
    public var type: TypeDeclaration

    public init(prefix: String? = nil, isConstant: Bool, identifier: String, type: TypeDeclaration) {
        self.prefix = prefix
        self.isConstant = isConstant
        self.identifier = identifier
        self.type = type
    }
}