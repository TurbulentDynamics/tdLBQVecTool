//
//  QVecLib.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation
import tdLBOutput

public enum Options {
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

    var plotDirByStep = [Int: [PlotDir]]()

    var xy = Velocity2DPlaneOrthoMultiXY<T>()
    var xz = Velocity2DPlaneOrthoMultiXZ<T>()
    var yz = Velocity2DPlaneOrthoMultiYZ<T>()

    public init(plotDirs dirs: [PlotDir]) {
        let fm = FileManager.default
        var isDirectory = ObjCBool(true)

        var root: URL?

        var validatedDirs = [PlotDir]()

        for d in dirs {
            if !fm.fileExists(atPath: d.path, isDirectory: &isDirectory) {
                fatalError("Dir do not exist \(d)")
            }

            if root == nil {
                root = d.deletingLastPathComponent()
                validatedDirs.append(d)
            } else if root != d.deletingLastPathComponent() {
                print("Ignoring Plot Dirs \(d)")
            } else {
                validatedDirs.append(d)
            }
        }
        groupByStep(plotDirs: validatedDirs)
    }

    public init(rootDir: OutputDir, kind: [PlotDirKind]) {

        var validatedDirs = [PlotDir]()

        for k in kind {
            validatedDirs.append(contentsOf: rootDir.plotDirs(withKind: k))
        }

        groupByStep(plotDirs: validatedDirs)

    }

    private mutating func groupByStep(plotDirs: [PlotDir]) {

        for p in plotDirs {
            if plotDirByStep.keys.contains(p.step()!) {
                plotDirByStep[p.step()!]?.append(p)
            } else {
                plotDirByStep[p.step()!] = [p]

            }

        }
    }

    /// Function to estimate the amount of time to process the files.  Could be 1000's
    public func analyse() {

        //DEBUG
        for (step, plotDirs) in plotDirByStep {
            for p in plotDirs {

                print("Analysing: step \(step), dir \(p.path)")
            }
        }
    }

    public mutating func process(opts: [Options]) {

        for (_, plotDirs) in plotDirByStep {

            for plotDir in plotDirs {

                switch plotDir.dirType() {
                    case .XYplane:
                        xy.loadPlane(withDir: plotDir)
                        if opts.contains(.velocities) {
                            xy.writeVelocity(to: plotDir, at: plotDir.cut()!, overwrite: opts.contains(.overwrite))
                        }
                    case .XZplane:
                        xz.loadPlane(withDir: plotDir)
                        if opts.contains(.velocities) {
                            xz.writeVelocity(to: plotDir, at: plotDir.cut()!, overwrite: opts.contains(.overwrite))
                        }
                    case .YZplane:
                        yz.loadPlane(withDir: plotDir)
                        if opts.contains(.velocities) {
                            yz.writeVelocity(to: plotDir, at: plotDir.cut()!, overwrite: opts.contains(.overwrite))
                        }
                    case .rotational:
                        continue
                    case .volume:
                        continue
                    case .none:
                        continue
                }

                if opts.contains(.vorticity) {

                    var keys = xy.p.keys
                    for k in keys {
                        if !(keys.contains(k-1)) {
                            xy.loadPlane(withDir: plotDir.formatCutDelta(delta: -1)!)
                        }
                        if !(keys.contains(k+1)) {
                            xy.loadPlane(withDir: plotDir.formatCutDelta(delta: +1)!)
                        }

                        if let vort = xy.calcVorticity(at: k) {
                            vort.writeVorticity(to: plotDir, overwrite: opts.contains(.overwrite))
                            
//                            vort.writeGrayscaleImage(to: plotDir)
                            
                            
                            
                            
                        } else {
                            print("Cannot call Vort")
                        }
                    }

                    keys = xz.p.keys
                    for k in keys {
                        if !(keys.contains(k-1)) {
                            xz.loadPlane(withDir: plotDir.formatCutDelta(delta: -1)!)
                        }
                        if !(keys.contains(k+1)) {
                            xz.loadPlane(withDir: plotDir.formatCutDelta(delta: +1)!)
                        }

                        if let vort = xz.calcVorticity(at: k) {
                            vort.writeVorticity(to: plotDir, overwrite: opts.contains(.overwrite))
                        } else {
                            print("Cannot call Vort")
                        }
                    }

                    keys = yz.p.keys
                    for k in keys {
                        if !(keys.contains(k-1)) {
                            yz.loadPlane(withDir: plotDir.formatCutDelta(delta: -1)!)
                        }
                        if !(keys.contains(k+1)) {
                            yz.loadPlane(withDir: plotDir.formatCutDelta(delta: +1)!)
                        }

                        if let vort = yz.calcVorticity(at: k) {
                            vort.writeVorticity(to: plotDir, overwrite: opts.contains(.overwrite))
                        } else {
                            print("Cannot call Vort")
                        }
                    }

                }//end of if opts.vorticity

            }//end of for plotDir in steps
        }
    }//end of struct

}
