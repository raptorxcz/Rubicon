//
//  TypeDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

enum TypePrefix: String, Equatable {
    case escaping = "@escaping"
    case autoclosure = "@autoclosure"
}

struct TypeDeclaration: Equatable {
    var name: String
    var isOptional: Bool
}
