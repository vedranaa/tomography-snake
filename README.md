# TomographySnake

A collection of functions and scripts which produces slightly simplified figures used in
our paper
[Computing segmentations directly from x-ray projection data via parametric deformable curves](https://iopscience.iop.org/article/10.1088/1361-6501/aa950e/meta). 
([Open-access, accepted author manuscript](https://backend.orbit.dtu.dk/ws/files/141005941/tomography.pdf).)

Please cite our paper, if you use our code in your research.

    @article{dahl2017computing,
        title={Computing segmentations directly from x-ray projection data via parametric deformable curves},
        author={Vedrana Andersen Dahl and Anders Bjorholm Dahl and Per Christian Hansen},
        journal={Measurement Science and Technology},
        volume={29},
        number={1},
        pages={014003},
        year={2017},
        publisher={{IOP} Publishing}
    }

## Using our code

Download the code, and run it in MATLAB. To produce the different results shown in our paper, you will need to change the
values of the settings and comment/uncomment pieces of code as indicated in the comments. Also, check our paper to see which value ranges are reasonable. The translation between variable names between the paper and the code is found below. 

Variable (setting) | in paper | in code | defaul value
------------ | ------------- | ------------- | -------------
Relative noise level | <img src="https://render.githubusercontent.com/render/math?math=\eta"> | `eta` | 0.1
Number of projection angles | *K* | `nr_angles` | 15
Number of detector pixels | *J* | `detector_number` | 200
Number of curve points | *N* | `N` | 500
Curve elasticity | <img src="https://render.githubusercontent.com/render/math?math=\alpha"> | `alpha` | 0.01
Curve rigidity | <img src="https://render.githubusercontent.com/render/math?math=\beta"> | `beta` | 0.01
Update step length | <img src="https://render.githubusercontent.com/render/math?math=\tau"> | `w` | 0.05
Number of iterations | *T* | `max_iter` | 500

<img src="/images/Figure7.png" width="500">

Illustration shows Figure 7 from our paper with default settings as in table above and interpretation as in table below.

Variable | in paper | in code 
------------ | ------------- | ------------- 
Test object | <img src="https://render.githubusercontent.com/render/math?math=\tilde{o}"> | `vertices` (for geometry) or `I` (for image)
Noise-free sinogram | <img src="https://render.githubusercontent.com/render/math?math=\tilde{s}"> | `sinogram_gt`
Noisy sinogram | *s* | `sinogram_target`
Resulting curve | <img src="https://render.githubusercontent.com/render/math?math=\mathbf{c}^\mathrm{end}"> | `current` (after evolution)
Resulting predicted sinogram | <img src="https://render.githubusercontent.com/render/math?math=p^\mathrm{end}"> | `current_sinogram` (after evolution)
Resulting residual | <img src="https://render.githubusercontent.com/render/math?math=s-p^\mathrm{end}"> | `residual` (after evolution)
Resulting reconstruction | <img src="https://render.githubusercontent.com/render/math?math=p^\mathrm{end}"> | obtained by `fill(current...)` 

## Additional requirements

Most of the scripts should run as-is. However, comparison with SART and DART (Figure 13) requires
[ASTRA toolbox](https://www.astra-toolbox.com/).
Additionaly, for forward projections in Figures 14-16 in the paper we use
[AIRtools](http://www.imm.dtu.dk/~pcha/AIRtoolsII/index.html),
but with a little bit of tweaking (as explained in the comments and included in code), `radon` function can be used instead.


