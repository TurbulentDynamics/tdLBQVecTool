# Turbulent Dynamics QVec Library

## Background
Turbulent Dynamics specialises in running high-resolution fluid dynamics simulations on supercomputers. The application decomposes the complete simulation space into smaller grids and each grid is run on one node. During the simulation each node creates output files independently. This application is used to stitch these files together and do some other post processing calculations.


1. Axes and Output planes
2. [QVec Format](QVec_format.md)
3. [Directory naming convention](Directory_Naming_Convention.md)
4. 2D Vector output
5. 3D Vector output
6. Other plots, eg Vorticity



## Getting Started
```
git clone --recursive https://github.com/TurbulentDynamics/tdQVecTool.git
cd tdQVecTool && swift build
./tdQVecTool -va Tests/TinyTestData
./tdQVecTool -v TD_Rushton_Sample_Output_QVec/plot_slice.XZplane.V_4.Q_4.step_00000200.cut_70
./tdQVecTool *

There is limit to number of arguments on Linux systems so the following can also be used
./tdQVecTool -a /path/to/rootdir
./tdQVecTool --blob "rootdir/*.XZplane*"
./tdQVecTool --xzplane rootdir


#The jupyter notebook in the "python" directory can be used to visualise the file created.
```



## Axes and XYZ Output Planes
The axes and direction are defined with X positive to the right, Y positive downwards and Z positive to the back.  The following image shows the axes and the name of the output planes that cut throught the simulation space.
![XYZ Planes](../XYZ_planes.jpg)







