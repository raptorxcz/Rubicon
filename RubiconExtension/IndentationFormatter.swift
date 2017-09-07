//
//  IndentationFormatter.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 13/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class IndentationFormatter {

    public init() {}

    public func format(indent: String, string: String) -> String {
        return string.replacingOccurrences(of: "\t", with: indent)
    }
}
