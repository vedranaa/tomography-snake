# TomographySnake

A collection of functions and scripts which produces slightly simplified figures used in
our paper
[Computing segmentations directly from x-ray projection data via parametric deformable curves](https://iopscience.iop.org/article/10.1088/1361-6501/aa950e/meta). Please cite our paper, if you use our code in your research.

    @article{dahl2017computing,
        title={Computing segmentations directly from x-ray projection data via parametric deformable curves},
        author={Dahl, Vedrana Andersen and Dahl, Anders Bjorholm and Hansen, Per Christian},
        journal={Measurement Science and Technology},
        volume={29},
        number={1},
        pages={014003},
        year={2017},
        publisher={IOP Publishing}
    }

## Using our code

Download the code, and run it in MATLAB. To produce the different results shown in our paper, you will need to change the
values of the settings and comment/uncomment pieces of code as indicated in the comments. Also, check our paper to see which values are reasonable.

Variable | in paper | in code | defaul value
------------ | ------------- | -------------
Relative noise level | <img src="https://render.githubusercontent.com/render/math?math=\eta"> | `eta` | 0.1
number of projection angles | *K* | `nr_angles` | 15
number of detector pixels | *J* | `detector_number` | 200
number of curve points | *N* | `N` | 500
curve elasticity | <img src="https://render.githubusercontent.com/render/math?math=\alpha"> | `alpha` | 0.01
curve rigidity | <img src="https://render.githubusercontent.com/render/math?math=\beta"> | `beta` | 0.01
update step length | <img src="https://render.githubusercontent.com/render/math?math=\tau"> | `w` | 0.05
number of iterations | *T* | `max_iter` | 500


Illustration shows Figure 7 from our paper with default settings.
    

Top
row: a test object ~o, a noise-free sinogram ~s, a noisy sinogram s,
and curve evolution showing every 25th iteration. Bottom row:
a resulting curve cend, a resulting predicted sinogram pend, a
resulting residual s􀀀pend, and a resulting reconstruction rend.
![Figure 7](/images/Figure7.png)

* test object $\tilda o$


## Requirements

Comparison with SART and DART (Figure 13) requires
[ASTRA toolbox](https://www.astra-toolbox.com/).
For forward projections in Figures 14-16 we use
[AIRtools](http://www.imm.dtu.dk/~pcha/AIRtoolsII/index.html),
but with a little bit of tweaking (as explained in the
comments), `radon` function can be used instead.


