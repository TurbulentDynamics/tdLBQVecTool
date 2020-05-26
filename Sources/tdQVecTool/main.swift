//
//  main.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 30/04/2019.
//

import Foundation
import ArgumentParser
import tdQVecLib
import tdLBApi


//Examples:
//./tdQVecTool -v *
//./tdQVecTool -va Tests/TinyTestData
//./tdQVecTool -vp TD_Rushton_Sample_Output_QVec/plot_slice.XZplane.V_4.Q_4.step_00000200.cut_70
//./tdQVecTool -a /path/to/outputdir
//./tdQVecTool --xzplane outputdir


//There is limit to number of arguments on Linux systems so the following can also be used
//./tdQVecTool --blob="rootdir/*"


//TODO
//./tdQVecTool --xzplane --step 800k-1m outputdir


enum ArgsErrors: Error {
    case blobInvalid
}



struct qVecTool: ParsableCommand {

    @Argument() var dirs: [String]


    @Flag(name: .shortAndLong, help: "Process All Sub Directories")
    var all: Bool


    @Flag(name: .shortAndLong, help: "Process all XY Plane Sub Directories")
    var xyplane: Bool

    @Flag(name: [.customShort("z"), .long], help: "Process all XY Plane Sub Directories")
    var xzplane: Bool

    @Flag(name: [.customShort("y"), .long], help: "Process all XY Plane Sub Directories")
    var yzplane: Bool

    @Flag(name: .shortAndLong, help: "Process all Rotation Sub Directories")
    var rotation: Bool

    @Flag(name: [.customShort("f"), .long], help: "Process all Full Volume Sub Directories")
    var volume: Bool




    @Flag(name: [.customShort("t"), .long], help: "Try Analyse All Directories")
    var analyse: Bool

    @Flag(name: .shortAndLong, help: "Overwrite output files if already exist")
    var overwrite: Bool

    @Flag(name: .shortAndLong, help: "Output ux uy uz files")
    var uxyz: Bool

    @Flag(name: .shortAndLong, help: "Output vorticity files")
    var vorticity: Bool

    @Flag(name: [.customShort("b"), .long], help: "Print verbose")
    var verbose: Bool


    //There is limit to number of arguments on Linux systems so the following can also be used
    @Option(name: .long, help: "Use a blob instead of passing dirs as *")
    var blob: String



    func run() throws {

        var processPlotDirs = [PlotDirKind]()
        var processOptions = [Options]()

        if all {
            processPlotDirs = [.XYplane, .XZplane, .YZplane, .rotational, .volume]
        }

        if xyplane {processPlotDirs.append(.XYplane)}
        if xzplane {processPlotDirs.append(.XZplane)}
        if yzplane {processPlotDirs.append(.YZplane)}
        if rotation {processPlotDirs.append(.rotational)}
        if volume {processPlotDirs.append(.volume)}


        if overwrite {processOptions.append(.overwrite)}
        if uxyz {processOptions.append(.velocities)}
        if vorticity {processOptions.append(.vorticity)}
        if verbose {processOptions.append(.verbose)}


        //TODO
        if blob.isEmpty {
            print(blob)
            throw ArgsErrors.blobInvalid
        }



        //Set up some defaults
        if processPlotDirs.isEmpty && dirs.count < 5 {
            processPlotDirs = [.XYplane, .XZplane, .YZplane, .rotational]
        }
        if processOptions.isEmpty {
            print("DEFAULT all options")
            processOptions = [.velocities, .vorticity]
        }



        //Sort the dirs into PlotDir and outputDirs
        var plotDirs = [PlotDir]()

        var root: URL?
        for d in dirs {
            do {
                let O = try OutputDir(rootDir: d)
                if root == nil {
                    root = O.root
                } else if root != O.root {
                    print("Either Plot Dirs or ONE root dir")
                    fatalError()
                }

            } catch diskErrors.PlotDir {
                plotDirs.append(PlotDir(fileURLWithPath: d))
            }
        }



        var q = try! QVecProcess(rootDir: root!, kind: processPlotDirs)
        q.analyse()
        q.process(opts: processOptions)
    }

}

qVecTool.main()




