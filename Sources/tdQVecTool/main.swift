//
//  main.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 30/04/2019.
//

import Foundation
import ArgumentParser
import tdQVecLib


//Examples:
//./tdQVecTool -v *
//./tdQVecTool -va Tests/TinyTestData
//./tdQVecTool -vp TD_Rushton_Sample_Output_QVec/plot_slice.XZplane.V_4.Q_4.step_00000200.cut_70
//./tdQVecTool -a /path/to/outputdir
//./tdQVecTool --xzplane outputdir

//TODO
//./tdQVecTool --xzplane --step 800k-1m outputdir

struct QVecTool: ParsableCommand {

    enum ArgsErrors: Swift.Error {
        case blobInvalid
    }

    ///dirs can be either a root Output Directory or a list of individual PlotDirs
    @Argument() var dirs: [String]

    @Flag(name: [.customShort("d"), .long], help: "Process RootDir")
    var rootDir: Bool

    @Flag(name: .shortAndLong, help: "Process All Sub Directories")
    var all: Bool

    @Flag(name: [.customShort("m"), .long], help: "Process from these step directories")
    var fromStep: Bool

    @Flag(name: .shortAndLong, help: "Process until these step directories")
    var toStep: Bool

    @Flag(name: .shortAndLong, help: "Process all XY Plane Sub Directories")
    var xyplane: Bool

    @Flag(name: [.customShort("y"), .long], help: "Process all XY Plane Sub Directories")
    var yzplane: Bool

    @Flag(name: [.customShort("z"), .long], help: "Process all XY Plane Sub Directories")
    var xzplane: Bool

    @Flag(name: .shortAndLong, help: "Process all Rotation Sub Directories")
    var rotation: Bool

    @Flag(name: [.customShort("f"), .long], help: "Process all Full Volume Sub Directories")
    var volume: Bool

    @Flag(name: [.customShort("n"), .long], help: "Analyse the Directories only (ie No output created)")
    var analyseOnly: Bool

    @Flag(name: .shortAndLong, help: "Overwrite files if they already exist")
    var overwrite: Bool

    @Flag(name: .shortAndLong, help: "Specifies ux, uy, and uz only")
    var uxyz: Bool

    @Flag(name: [.customShort("v"), .long], help: "Specifies vorticity only")
    var vorticity: Bool

    @Flag(name: [.customShort("s"), .long], help: "Verbose output")
    var verbose: Bool

    func run() throws {

        var processPlotDirs = [PlotDirKind]()
        var processOptions = [Options]()

        if xyplane {processPlotDirs.append(.XYplane)}
        if xzplane {processPlotDirs.append(.XZplane)}
        if yzplane {processPlotDirs.append(.YZplane)}
        if rotation {processPlotDirs.append(.rotational)}
        if volume {processPlotDirs.append(.volume)}

        if all {
            processPlotDirs = [.XYplane, .XZplane, .YZplane, .rotational, .volume]
        }

        if overwrite {processOptions.append(.overwrite)}
        if uxyz {processOptions.append(.velocities)}
        if vorticity {processOptions.append(.vorticity)}
        if verbose {processOptions.append(.verbose)}

        //Set up some defaults
        if processPlotDirs.isEmpty && dirs.count < 5 {
            processPlotDirs = [.XYplane, .XZplane, .YZplane, .rotational]
        }
        if processOptions.isEmpty {
            print("Using default: all options")
            processOptions = [.velocities, .vorticity]
        }

        var q: QVecLib<Float32>
        if rootDir {

            if dirs.count > 1 {
                fatalError("Only one Root Output Dir is allowed.")
            }

            var O: OutputDir
            do {
                O = try OutputDir(rootDir: dirs[0])

            } catch diskErrors.isPlotDir {
                print("Fail. init with root dir and options")
                fatalError()
            }

            q = QVecLib(rootDir: O, kind: processPlotDirs)

        } else {
            let plotDirs = dirs.map({PlotDir(fileURLWithPath: $0, isDirectory: true)})
            q = QVecLib(plotDirs: plotDirs)
        }

        q.analyse()

        if !analyseOnly {
            q.process(opts: processOptions)
        }

    }

}

QVecTool.main()
