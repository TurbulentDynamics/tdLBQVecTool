# tdQVec Format

Lattice Boltzmann simulations model the space in discrete volumes, (also in 2D).  Each of these "Cells" are represented by a number of vectors depending on the algorithm used, eg D2Q9, D3Q19, D3Q28, with the vector directions shown below.  These vectors are normally arranged with the faces first, edges second and corners third.  The tdQVec format can output any combination of these and in any length, FP16, FP32, or FP64.  Sometimes the vectors are a dense volume and sometimes the coordinates are included in sparse simulations.



## File Types QVec and QVec.F3
QVec contains the vectors from Lattice Boltzmann cells, of length 5, 9, 19 or 27, and QVec.F3 always contains 3 "Forcing" vectors along the major axes.  Each .bin file has a corresponding .bin.json file containing metadata.


### File naming convention
Qvec.node.X.Y.Z.V4.bin or Qvec.F3.node.X.Y.Z.V4.bin
node.X.Y.Z is the output from the node with cartesian coordinates X, Y, Z
V4: Version 4
The length of vectors is found from either the bin.json or the directory name.

