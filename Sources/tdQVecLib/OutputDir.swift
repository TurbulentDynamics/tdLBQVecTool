//
//  InputFilesV4URL.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation


public enum diskErrors: Error {
    case fileNotFound
    case directoryNotFound
    case fileNotReadable
    case fileNotJsonParsable
    case isPlotDir
    case isNotPlotDir
    case OtherDiskError
}



///An OutputDir is a the path of a local file on disk that exists and is writable or is created and writable
public struct OutputDir {

//    public let fm = FileManager.default

    public let root:URL


    let PlotFilesVersion:Int = 4




    /// Initialize with string.
    ///
    /// Throws an error if `URL` cannot be formed with the string or the directory cannot be created
    public init(rootDir: String, createDir: Bool = false) throws {


        if rootDir.contains("V_\(PlotFilesVersion)") {
            throw diskErrors.isPlotDir
        }


        self.root = URL(fileURLWithPath: rootDir, isDirectory: true)

        if createDir {
            try createDirIfDoesntExist(rootDir)
            // TODO: Check can write directory below
        }

    }



    public init() throws {
        let fm = FileManager.default
        let dir = fm.currentDirectoryPath
        try self.init(rootDir: dir)
    }

    #if os(macOS)
    public init(rootDirInHome: String, createDir: Bool = false) throws {
        let fm = FileManager.default
        let dir = fm.homeDirectoryForCurrentUser.appendingPathComponent(rootDirInHome).path
        try self.init(rootDir: dir, createDir: createDir)
    }
    #endif

    public init(rootDir: URL, createDir: Bool = false) throws {
        try self.init(rootDir: rootDir.path,  createDir: createDir)
    }



    private func createDirIfDoesntExist(_ dir:String) throws {
        let fm = FileManager.default

        var isDirectory = ObjCBool(true)
        if !fm.fileExists(atPath: dir, isDirectory: &isDirectory){

            try fm.createDirectory(atPath: dir, withIntermediateDirectories: false)
        }
    }







    // MARK: Getting Plot Dirs

    private func getPlotDirs(withRegex regex: String) -> [PlotDir] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526
        let fm = FileManager.default

        var directoryContents: [URL]

        do {
            directoryContents = try fm.contentsOfDirectory(at: self.root, includingPropertiesForKeys: nil)
        } catch {
            return [PlotDir]()
        }

        let filteredDirNames = directoryContents.filter{$0.hasDirectoryPath && $0.lastPathComponent.range(of: regex, options:.regularExpression) != nil}

        return filteredDirNames

    }


    private func formatVersion(_ version: Int) -> String {
        return "V_\(version)"
    }

    private func formatQLength(_ QLength: Int) -> String {
        return "Q_\(QLength)"
    }

    private func formatStep(_ step: Int) -> String {
        return String(format: "step_%08d", step)
    }



    // TODO:
//    func formatRotatingSector(name: String="plot", step: Int, angle: Int, QLength: Int) -> String {
//        return "TODO"
//    }



    public func plotDirs() -> [PlotDir] {
        return getPlotDirs(withRegex: ".*")
    }


    public func plotDirs(withKind kind: PlotDirKind) -> [PlotDir] {
        switch kind {
            case .XYplane:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.XYplane.self).*")
            case .XZplane:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.XZplane.self).*")
            case .YZplane:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.YZplane.self).*")
            case .volume:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.volume.self).*")
            case .rotational:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.rotational.self).*")
        }
    }


    public func plotDirs(withVersion version: Int) -> [PlotDir] {
        return getPlotDirs(withRegex: ".*\(formatVersion(version)).*")
    }

    public func plotDirs(withQLength QLength: Int) -> [PlotDir] {
        return getPlotDirs(withRegex: ".*\(formatQLength(QLength)).*")
    }

    public func plotDirs(withStep step: Int) -> [PlotDir] {
        return getPlotDirs(withRegex: ".*\(formatStep(step)).*")
    }




    // MARK: Creating Plot Dirs



    private func createPlotDir(_ plotDir: String) -> PlotDir {

        let newPlotDir:String = self.root.appendingPathComponent(plotDir).path


        do {
            try createDirIfDoesntExist(newPlotDir)
        } catch {
            //TODO:  Previously tests that permissions are writable on rootdir.  Other errors may be generated here, full disk etc that could cause problems.
            print(error.localizedDescription)
        }

        let dir = PlotDir(fileURLWithPath: newPlotDir, isDirectory: true)

        return dir
    }



    private func formatPlotDirRoot(name: String, kind: PlotDirKind, QLength: Int, step: Int) -> String {
        return "\(name).\(kind.rawValue).\(formatVersion(self.PlotFilesVersion)).\(formatQLength(QLength)).\(formatStep(step))"
    }



    public func formatXYPlane(name: String = "plot_vertical_axis", QLength: Int, step: Int, atK: Int) -> String {

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.XYplane, QLength: QLength, step: step)
        return "\(root).cut_\(atK)"
    }

    public func createXYPlane(name: String = "plot_vertical_axis", QLength: Int, step: Int, atK: Int) -> PlotDir {

        return createPlotDir(formatXYPlane(name:name, QLength: QLength, step: step, atK: atK))
    }



    public func formatXZPlane(name: String = "plot_slice", QLength: Int, step: Int, atJ: Int) -> String{

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.XZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atJ)"
    }

    public func createXZPlane(name: String = "plot_slice", QLength: Int, step: Int, atJ: Int) -> PlotDir {

        return createPlotDir(formatXZPlane(name:name, QLength: QLength, step: step, atJ: atJ))
    }



    public func formatYZPlane(name: String = "plot_axis", QLength: Int, step: Int, atI: Int) -> String {

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.YZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atI)"
    }

    public func createYZPlane(name: String = "plot_axis", QLength: Int, step: Int, atI: Int) -> PlotDir {

        return createPlotDir(formatYZPlane(name:name, QLength: QLength, step: step, atI: atI))
    }




    public func formatVolume(name: String = "volume", QLength: Int, step: Int) -> String {

        return formatPlotDirRoot(name: name, kind: PlotDirKind.volume, QLength: QLength, step: step)
    }



    public func formatCaptureAtBladeAngle(name: String="plot", step: Int, angle: Int, bladeId: Int, QLength: Int) -> String {

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.rotational, QLength: QLength, step: step)
        return "\(root).angle_\(angle).blade_id_\(bladeId)"
    }

    public func formatAxisWhenBladeAngle(name: String="plot", step: Int, angle: Int, QLength: Int) -> String {

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.YZplane, QLength: QLength, step: step)
        return "\(root).angle_\(angle)"
    }








}

