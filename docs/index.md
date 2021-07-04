# Turbulent Dynamics QVec Library

## Background
Turbulent Dynamics specialises in running high-resolution fluid dynamics simulations on supercomputers. The application decomposes the complete simulation space into smaller grids and each grid is run on one node. During the simulation each node creates output files independently. This application is used to stitch these files together and do some other post processing calculations.


1. [Axes and output planes](Axes_and_output_planes.md)
2. [QVec format](tdQVec_format.md)
3. [Directory naming convention](Directory_naming_convention.md)
4. 2D Vector output
5. 3D Vector output
6. Other plots, eg Vorticity



## Getting Started
```
git clone https://github.com/TurbulentDynamics/tdLBQVecTool.git
cd tdLBQVecTool && swift build
./tdLBQVecTool --vorticity --all SmallSampleData
./tdLBQVecTool --vorticity SmallSampleData/plot_slice.XZplane.V5.step_00000050.cut_29 
./tdLBQVecTool *
```

There is limit to number of arguments on Linux systems so the following can also be used
```./tdLBQVecTool --all /path/to/rootdir
./tdLBQVecTool --blob "rootdir/*.XZplane*"
./tdLBQVecTool --xzplane rootdir
```
Larger Sample data available in a git-lfs repo 
`git clone https://github.com/TurbulentDynamics/tdQVecRushtonTurbineSampleOutput.git`
```
46M    plot_output_np64_gridx160
131M    plot_output_np8_gridx268
3.4M    plot_output_np8_gridx44
181M    total
```

![Impeller Vorticity](docs/Impeller_Vorticity.jpg)

## Axes and XYZ Output Planes
The axes and direction are defined with X positive to the right, Y positive downwards and Z positive to the back.  The following image shows the axes and the name of the output planes that cut throught the simulation space.
![XYZ Planes](XYZ_planes.jpg)







