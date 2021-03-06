# TomographySnake

A collection of functions and scripts which produces slightly simplified figures used in
our paper
[Computing segmentations directly from x-ray projection data via parametric deformable curves](https://iopscience.iop.org/article/10.1088/1361-6501/aa950e/meta). 
(Open-access accepted author version of the manuscript can be found [here](https://backend.orbit.dtu.dk/ws/files/141005941/tomography.pdf).)
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
    
<img src="/images/Figure7_sp.png" width="700">

Illustration (Figure 7 from our paper) shows,\
*top row*: test object, noise-free sinogram, noisy sinogram, evolution of the curve starting from the circle;\
*bottom row*: resulting curve, resulting predicted sinogram, resulting residual and resulting reconstruction.     

## Using our code

Download the code, and run it in MATLAB. To produce the different results shown in our paper, you will need to change the
values of the settings and comment/uncomment pieces of code as indicated in the comments. Also, check our paper to see which value ranges are reasonable. The translation between variable names in the paper and in the code is found below. 

Variable (setting) | in paper | in code | defaul value
------------ | ------------- | ------------- | -------------
Relative noise level | <img src="https://render.githubusercontent.com/render/math?math=\eta"> | `eta` | 0.1
Number of projection angles | <img src="https://render.githubusercontent.com/render/math?math=K"> | `nr_angles` | 15
Number of detector pixels | <img src="https://render.githubusercontent.com/render/math?math=J"> | `detector_number` | 200
Number of curve points | <img src="https://render.githubusercontent.com/render/math?math=N"> | `N` | 500
Curve elasticity | <img src="https://render.githubusercontent.com/render/math?math=\alpha"> | `alpha` | 0.01
Curve rigidity | <img src="https://render.githubusercontent.com/render/math?math=\beta"> | `beta` | 0.01
Update step length | <img src="https://render.githubusercontent.com/render/math?math=\tau"> | `w` | 0.05
Number of iterations | <img src="https://render.githubusercontent.com/render/math?math=T"> | `max_iter` | 500

Variable | in paper | in code 
------------ | ------------- | ------------- 
Test object | <img src="https://render.githubusercontent.com/render/math?math=\tilde{o}"> | `vertices` (for geometry) or `I` (for image)
Noise-free sinogram | <img src="https://render.githubusercontent.com/render/math?math=\tilde{s}"> | `sinogram_gt`
Noisy sinogram | <img src="https://render.githubusercontent.com/render/math?math=s"> | `sinogram_target`
Resulting curve | <img src="https://render.githubusercontent.com/render/math?math=\mathbf{c}^\mathrm{end}"> | `current` (after evolution)
Resulting predicted sinogram | <img src="https://render.githubusercontent.com/render/math?math=p^\mathrm{end}"> | `current_sinogram` (after evolution)
Resulting residual | <img src="https://render.githubusercontent.com/render/math?math=s-p^\mathrm{end}"> | `residual` (after evolution)
Resulting reconstruction | <img src="https://render.githubusercontent.com/render/math?math=p^\mathrm{end}"> | obtained by `fill(current...)` 

## Additional requirements

Most of the scripts should run as-is. However, comparison with SART and DART (Figure 13) requires
[ASTRA toolbox](https://www.astra-toolbox.com/).
Additionally, for forward projections in Figures 14-16 we use
[AIRtools](http://www.imm.dtu.dk/~pcha/AIRtoolsII/index.html) for results included in the paper. However, with a little bit of tweaking (as explained in the comments and included in the code), `radon` function can be used instead.


