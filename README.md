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

Illustration shows Figure 7 from our paper. This is an experiment with default settings.
    
    eta = 0.1; % relative noise level
    nr_angles = 15; % number of projection angles, K in article
    detection_number = 200; % number of detector pixels, J in article
    N = 500; % number of curve points
    alpha = 0.01; % curve elasticity
    beta = 0.01; % curve rigidity
    w = 0.05; % update step length, tau in article
    max_iter = 500; % no. iterations

`$z = x + y$`

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


