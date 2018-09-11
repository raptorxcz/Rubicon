//
//  FileReaderImpl.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 08/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation

public class FileReaderImpl: FileReader {

    public func readFiles(at path: String) -> [String] {
        let fileNames = findFileNames(at: path)
        let contentOfFiles = fileNames.compactMap({ try? String(contentsOfFile: $0, encoding: .utf8) })
        return contentOfFiles
    }

    private func findFileNames(at path: String) -> [String] {
        let fileManager = FileManager.default

        var fileNames = [String]()

        let items = try! FileManager.default.contentsOfDirectory(atPath: path)

        for fileName in items {
            let itemPath = path + "/" + fileName

            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: itemPath, isDirectory: &isDir) {
                if isDir.boolValue {
                    fileNames += findFileNames(at: itemPath)
                } else {
                    if fileName.hasSuffix(".swift") {
                        fileNames.append(itemPath)
                    }
                }
            }
        }

        return fileNames
    }
}
