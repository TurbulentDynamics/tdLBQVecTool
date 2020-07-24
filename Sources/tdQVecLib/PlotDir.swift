//
//  InputFilesV4URL.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation




public enum PlotDirKind: String {
    case XYplane = "XYplane"
    case XZplane = "XZplane"
    case YZplane = "YZplane"
    case rotational = "rotational_capture"
    case volume = "volume"
    //    case sector = "sector"
}



enum binExt: String {
    case bin = "bin"
    case binJson = "bin.json"

    case rho = "rho.bin"

    case ux = "ux.bin"
    case uy = "uy.bin"
    case uz = "uz.bin"

    case vorticity = "vorticity.bin"


}





// TODO: Is there a better way to do this?
public typealias PlotDir = URL


public extension URL {


    var OutputFilesURLVersion: Int {
        return 4
    }





    func isValid() -> Bool {
        return self.hasDirectoryPath && self.lastPathComponent.contains(".V_4.")
    }

    func exists() -> Bool {
        let fm = FileManager.default
        var isDirectory = ObjCBool(true)
        return fm.fileExists(atPath: self.path, isDirectory: &isDirectory)
    }

    func isValidAndExists() -> Bool {
        return isValid() && exists()
    }


    


    // MARK: Query plotDirs


    func name() -> String? {
        return self.lastPathComponent.components(separatedBy: ".")[0]
    }

    func dirType() -> PlotDirKind? {

        if self.lastPathComponent.contains(".\(PlotDirKind.XYplane.rawValue).") {return .XYplane}
        else if self.lastPathComponent.contains(".\(PlotDirKind.XZplane.rawValue).") {return .XZplane}
        else if self.lastPathComponent.contains(".\(PlotDirKind.YZplane.rawValue).") {return .YZplane}
        else if self.lastPathComponent.contains(".\(PlotDirKind.volume.rawValue).") {return .volume}
        else if self.lastPathComponent.contains(".\(PlotDirKind.rotational.rawValue).") {return .rotational}
            //        else if self.lastPathComponent.contains(".sector.") {return .sector}
        else {
            return nil
        }
    }



    func version() -> Int? {
        let plotdir = self.lastPathComponent
        if let result = plotdir.range(of: #"V_([0-9]*)"#, options: .regularExpression){
            let i = plotdir[result].index(plotdir[result].startIndex, offsetBy: 2)
            return Int(plotdir[result][i...])
        } else {
            return nil
        }
    }

    func qLength() -> Int? {
        let plotdir = self.lastPathComponent
        if let result = plotdir.range(of: #"Q_([0-9]*)"#, options: .regularExpression){
            let i = plotdir[result].index(plotdir[result].startIndex, offsetBy: 2)
            return Int(plotdir[result][i...])
        } else {
            return nil
        }
    }

    func step() -> Int? {
        let plotdir = self.lastPathComponent
        if let result = plotdir.range(of: #"step_([0-9]*)"#, options: .regularExpression){
            let i = plotdir[result].index(plotdir[result].startIndex, offsetBy: 5)
            return Int(plotdir[result][i...])
        } else {
            return nil
        }
    }


    func cut() -> Int? {
        let plotdir = self.lastPathComponent
        if let result = plotdir.range(of: #"cut_([0-9]*)"#, options: .regularExpression){
            let i = plotdir[result].index(plotdir[result].startIndex, offsetBy: 4)
            return Int(plotdir[result][i...])
        } else {
            return nil
        }
    }


    func replaceLastPathComponent(newLastPathComp path: String) -> PlotDir {

        let root = self.deletingLastPathComponent()
        return root.appendingPathComponent(path)

    }

    var lastTwoPathComponents: String {

        let u = self.lastPathComponent
        let v = self.deletingLastPathComponent()
        return v.lastPathComponent + "/" + u
    }



    func formatCutDelta(delta: Int) -> PlotDir? {
        if let cut = self.cut() {
            let replace: String = "cut_\(cut + delta)"

            let newDir = self.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            return replaceLastPathComponent(newLastPathComp: newDir)
        } else {
            return nil
        }
    }


    func formatCutDelta(replaceCut: Int) -> PlotDir? {
        if let _ = self.cut() {

            let replace: String = "cut_\(replaceCut)"

            let newDir = self.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            return replaceLastPathComponent(newLastPathComp: newDir)
        } else {
            return nil

        }
    }







    // MARK: Working with Files within a PlotDir


    func getFiles(withRegex regex: String) -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let fm = FileManager.default

        var directoryContents:[URL]

        do {
            directoryContents = try fm.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)

        } catch {
            print(error)
            return [URL]()
        }

        let fileNames = directoryContents.map{ $0.lastPathComponent }

        let filteredBinFileNames = fileNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}




        let filteredBinFileURLs = filteredBinFileNames.map{self.appendingPathComponent($0)}

        return filteredBinFileURLs

    }




    func qVecBinRegex() -> String {
        return "^Qvec\\.node\\..*\\.bin$"
    }

    func F3BinRegex() -> String {
        return "^Qvec\\.F3\\.node\\..*\\.bin$"
    }

    //    private func faceDeltas() -> [facesIJK] {
    //        return facesIJK.allCases
    //    }
    //
    //    private func qVecRotationBinRegex(delta: facesIJK) -> String {
    //        return "^Qvec\\.\(delta)\\.node\\..*\\.bin$"
    //    }
    //
    //    private func F3RotationBinRegex(delta: facesIJK) -> String {
    //        return "^Qvec\\.F3\\.\(delta)\\.node\\..*\\.bin$"
    //    }


    //    func getQvecRotationFiles(faceDelta: facesIJK) -> [URL] {
    //        return try getFiles(withRegex: qVecRotationBinRegex(delta: faceDelta))
    //    }
    //
    //    func getF3RotationFiles(faceDelta: facesIJK) -> [URL] {
    //        return try getFiles(withRegex: F3RotationBinRegex(delta: faceDelta))
    //    }




    func getQvecFiles() -> [URL] {
        return getFiles(withRegex: qVecBinRegex())
    }

    func getF3Files() -> [URL] {
        return getFiles(withRegex: F3BinRegex())
    }




    // MARK: Formatting names of bin and bin.json files

    /// Returns the name of the meta information file that holds data of the Plot contained in PlotDir.
    func ppDimURL() -> URL {
        return self.appendingPathComponent("Post_Processing_Dims_dims.0.0.0.V\(self.OutputFilesURLVersion).json")
    }




    private func formatQVecFile(_ name: String, _ idi: Int, _ idj: Int, _ idk: Int, _ ext: binExt) -> String {
        return "\(name).node.\(idi).\(idj).\(idk).V\(self.OutputFilesURLVersion).\(ext.rawValue)"
    }




    func QVecBinFileURL(name: String, idi: Int, idj: Int, idk: Int) -> URL {

        return self.appendingPathComponent(formatQVecFile(name, idi, idj, idk, .bin))
    }

    func QVecBinFileJSON(name: String, idi: Int, idj: Int, idk: Int) -> URL {

        return self.appendingPathComponent(formatQVecFile(name, idi, idj, idk, .binJson))
    }






    func node000QVecBinFileURL(name: String) -> URL {

        return QVecBinFileURL(name: name, idi: 0, idj: 0, idk: 0)
    }

    func node000QVecBinFileJSON(name: String) -> URL {

        return QVecBinFileJSON(name: name, idi: 0, idj: 0, idk: 0)
    }








    private func xURL(to writeDir: URL? = nil, ext: binExt) -> URL {

        let fileName = "\(self.lastPathComponent).\(ext.rawValue)"

        if let dir = writeDir {
            return dir.appendingPathComponent(fileName)
        }

        return self.appendingPathComponent(fileName)
    }


    func rhoURL(to writeDir: URL? = nil) -> URL {
        return xURL(to: writeDir, ext: .rho)
    }
    func uxURL(to writeDir: URL? = nil) -> URL {
        return xURL(to: writeDir, ext: .ux)
    }
    func uyURL(to writeDir: URL? = nil) -> URL {
        return xURL(to: writeDir, ext: .uy)
    }
    func uzURL(to writeDir: URL? = nil) -> URL {
        return xURL(to: writeDir, ext: .uz)
    }
    func vorticityURL(to writeDir: URL? = nil) -> URL {
        return xURL(to: writeDir, ext: .vorticity)
    }








}










