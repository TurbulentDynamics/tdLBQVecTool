//
//  QVecLib.swift
//  tdLBQVecTool
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation
import tdLB

//https://gist.github.com/asmallteapot/5bef591b22ef59f7a27bd1d3a0a8ff8f
extension Dictionary where Value: RangeReplaceableCollection {

    public mutating func appendAtKey(_ key: Key, _ element: Value.Iterator.Element) {

        var value: Value = self[key] ?? Value()
        value.append(element)
        self[key] = value
        //        return value
    }

    public mutating func insert(_ key: Key, _ element: Value.Iterator.Element) -> Value? {

        var value: Value = self[key] ?? Value()
        value.append(element)
        self[key] = value
        return value
    }
}

public enum OutputOptions {
    case velocities
    case vorticity
    case overwrite
    case verbose
}

public enum Reference {
    case relative
    case absolute
}

public struct QVecLib<T: BinaryFloatingPoint> {

    let outputTree: DiskOutputTree

    var plotDirs = [PlotDirKind: [tStep: [URL]]]()


    public init(outputTree: DiskOutputTree, dirs: [String], kind: [PlotDirKind]) {

        self.outputTree = outputTree

        self.plotDirs[.xyPlane] = groupByStep(dirs: self.outputTree.findOrthoPlaneDirs(orientation: .xyPlane))
        self.plotDirs[.xzPlane] = groupByStep(dirs: self.outputTree.findOrthoPlaneDirs(orientation: .xzPlane))
        self.plotDirs[.yzPlane] = groupByStep(dirs: self.outputTree.findOrthoPlaneDirs(orientation: .yzPlane))
    }

    private func groupByStep(dirs: [URL]) -> [tStep: [URL]] {

        var dirByStep = [tStep: [URL]]()

        for plotDir in dirs {

            if let hasStep = self.outputTree.step(dir: plotDir) {
                dirByStep.appendAtKey(hasStep, plotDir)
            }
        }
        return dirByStep
    }

    ///Function to estimate the amount of time to process the files.  Could be 1000's
    public func analyse() {

        for kind in PlotDirKind.allCases {
            for (step, dirs) in self.plotDirs[kind]! {

                print("TODO")
                print("Step \(step)   Type \(kind) has \(dirs.count)")

        //        //DEBUG
        //        for (kind, plotDirs) in self.plotDirByStep {
        //
        //            for p in plotDirs {
        //                //TODO
        //                print("TODO: Analysing: step \(step), dir \(p.path)")
        //            }
        //        }
            }

        }

    }

    
    
    public func process(opts: [OutputOptions]) {

        for kind in PlotDirKind.allCases {
            for (step, dirs) in self.plotDirs[kind]! {

                var xy = Velocity2DPlaneOrthoMultiXY<T>()
                for dir in dirs {

                    //TODO check opts.contains(.overwrite)

                    let files = self.outputTree.findQVecBin(at: dir)
                    
                    var (x, y, z) = self.outputTree.confirmGridSizes(from: files)
                    
                    
                    
                    
                    let jsonFile = self.outputTree.qVecBinFileJSON(plotDir: dir, idi: 0, idj: 0, idk: 0)

                    let cutAt = 10//json.cutAt

                    xy.loadBinFiles(files: files, cols: x, rows: y, cutAt: cutAt)
                }

                for dir in dirs {
                    let json = self.outputTree.loadBinFileJson(from: dir)
                    let cutAt = 10//json.cutAt

                    xy[cutAt].writeRho(to: self.outputTree.rho(for: dir))
                    xy[cutAt].writeUX(to: self.outputTree.ux(for: dir))
                    xy[cutAt].writeUY(to: self.outputTree.uy(for: dir))
                    xy[cutAt].writeUZ(to: self.outputTree.uz(for: dir))

                    let vort: Vorticity2D<T> = try! xy.calcXYVorticity(at: cutAt)!

                    vort.writeVorticity(to: dir)

                    vort.writeGrayscaleImage(to: self.outputTree.vorticity(for: dir), withBorder: 2)

                }

            }
        }
    }

}//end of struct
