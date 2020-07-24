import XCTest
@testable import tdQVecLib

class PlotDirTests: XCTestCase {

    let testRootDirURL = URL(fileURLWithPath: "testRootDir", isDirectory: true)

    let testDirStrings = [
        "plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_10",
        "plot_slice.XZplane.V_4.Q_4.step_00000010.cut_10",
        "plot_axis.YZplane.V_4.Q_4.step_00000010.cut_10"
    ]
    var testDirURLs = [URL]()

    
    override func setUp() {
        super.setUp()

        //Ensure testRootDir does not exist
        do {
            let fm = FileManager.default
            try fm.removeItem(at: testRootDirURL)
        } catch {
            //Item probably didnt exist
        }

        testDirURLs = testDirStrings.map{ testRootDirURL.appendingPathComponent($0, isDirectory: true) }

        for t in testDirURLs {
            let fm = FileManager.default
            try! fm.createDirectory(at: t, withIntermediateDirectories: true)
        }
    }


    override func tearDown() {
        super.tearDown()
        do {
            let fm = FileManager.default
            try fm.removeItem(at: testRootDirURL)
        } catch {
            //Some tests failed and Dir was not created
        }
    }



    func testOutputDirInitWhenDirExists() {

        let p = PlotDir(fileURLWithPath: testDirURLs[0].path, isDirectory: true)
        XCTAssertEqual(testDirURLs[0].path, p.path)
        
        XCTAssert(p.exists())
        XCTAssert(p.isValid())
        XCTAssert(p.isValidAndExists())
    }



    func testQVecBinFILESAndJson() {

        let plotDir = PlotDir(fileURLWithPath: "testPlotDir", isDirectory: true)

        let url = plotDir.QVecBinFileURL(name:"plot_dir", idi:1, idj:1, idk:1)
        XCTAssertEqual(url.lastPathComponent, "plot_dir.node.1.1.1.V4.bin")


        let urlJSON = plotDir.QVecBinFileJSON(name:"plot_dir", idi:1, idj:1, idk:1)
        XCTAssertEqual(urlJSON.lastPathComponent, "plot_dir.node.1.1.1.V4.bin.json")

    }



    func testVelocityURLs() {

        let p = PlotDir(fileURLWithPath: testDirURLs[0].path, isDirectory: true)

        let newOutDirURL = URL(fileURLWithPath: "/ExternalOutDir", isDirectory: true)

        XCTAssertEqual(p.rhoURL().lastTwoPathComponents, "plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_10/plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_10.rho.bin")

        XCTAssertEqual(p.rhoURL(to: newOutDirURL).lastTwoPathComponents, "ExternalOutDir/plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_10.rho.bin")



        XCTAssertEqual(p.uxURL().lastTwoPathComponents, "plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_10/plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_10.ux.bin")

        XCTAssertEqual(p.uxURL(to: newOutDirURL).lastTwoPathComponents, "ExternalOutDir/plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_10.ux.bin")

    }



    func testFormatCutDelta() {
        let p = PlotDir(fileURLWithPath: testDirURLs[0].path, isDirectory: true)

        let u = p.replaceLastPathComponent(newLastPathComp: "test")
        XCTAssertEqual(u.lastPathComponent, "test")


        XCTAssertEqual(p.formatCutDelta(delta: -1)?.lastPathComponent, "plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_9")

        XCTAssertEqual(p.formatCutDelta(replaceCut: 9999)?.lastPathComponent, "plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_9999")

    }



    //    static var allTests = [
    //        ("testOutputDirInitWhenDirExists", testOutputDirInitWhenDirExists),
    //    ]
}
