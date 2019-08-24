//
//  main.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 30/04/2019.
//

import Foundation
import tdQVecCore

//./tdQVecTool -va Tests/TinyTestData
//./tdQVecTool -v TD_Rushton_Sample_Output_QVec/plot_slice.XZplane.V_4.Q_4.step_00000200.cut_70
//./tdQVecTool *
//
//There is limit to number of arguments on LInux systems so the following can also be used
//./tdQVecTool -a /path/to/rootdir
//./tdQVecTool --blob "rootdir/*.XZplane*"
//./tdQVecTool --xzplane rootdir





let argData = [
    ("a", "all", "Process all directories"),
    ("z", "xyplane", ""),
    ("y", "xzplane", ""),
    ("x", "yzplane", ""),
    ("r", "rotation", ""),
    ("f", "volume", "Full volume"),

    ("t", "analyse", "Try analyse"),
    ("o", "overwrite", "Overwrite output files if already exist"),
    ("u", "uxyz", "Output ux uy uz files"),
    ("v", "vorticity", "Output vorticity files"),
    ("p", "print", "Print verbose"),
    ("h", "help", ""),
]




if CommandLine.arguments.contains("-h") || CommandLine.arguments.contains("--help") {
    print("USAGE: tdQVecTool [options] <directories>")

    for o in argData {
        print("\t -\(o.0) --\(o.1) \t \(o.2)")
    }
    exit(0)
}



extension String {
    func dropFirst(_ at: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: at)
        return String(self[start...]).lowercased()
}
}


var verifiedArgs = [String]()
var dirs = [String]()

for a in CommandLine.arguments.dropFirst() {

    if a.hasPrefix("--") {
        for o in argData {
            if o.1 == a.dropFirst(2) {

            verifiedArgs.append(o.1)
            }
            }

        } else if a.hasPrefix("-") {

        for m in Array(a.dropFirst(1)) {

        for o in argData {

            if String(m) == o.0 {
                  verifiedArgs.append(o.1)
            }

        }
        }
    } else {
            dirs.append(a)
        }
    }






if dirs.isEmpty {
    print("Must enter at least one dir as an argument")
    exit(1)
}

var processDirTypes = [DirType]()
var processOptions = [Options]()
for v in verifiedArgs {
    switch v {
        case "all":
            processDirTypes = [.XYplane, .XZplane, .YZplane, .rotational, .volume]
        case "xyplane":
            processDirTypes.append(.XYplane)
        case "xzplane":
            processDirTypes.append(.XZplane)
        case "yzplane":
            processDirTypes.append(.YZplane)
        case "rotation":
            processDirTypes.append(.rotational)
        case "volume":
            processDirTypes.append(.volume)

        
        case "overwrite":
            processOptions.append(.overwrite)
        case "uxyz":
            processOptions.append(.velocities)
        case "vorticity":
            processOptions.append(.vorticity)
        case "verbose":
            processOptions.append(.verbose)
        default:
            continue
    }
}




if verifiedArgs.contains("all")  && processDirTypes.count > 5 {
    print("Args contain all and another dir type")
    exit(1)
}




//Set up some defaults
if processDirTypes.isEmpty && dirs.count < 5 {
    processDirTypes = [.XYplane, .XZplane, .YZplane, .rotational]
}
if processOptions.isEmpty {
    print("DEFAULT all options")
    processOptions = [.velocities, .vorticity]
}








let q = QVecProcess(dirs: dirs, dirTypes: processDirTypes)

q.analyse()

q.process(opts: processOptions)




