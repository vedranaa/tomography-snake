# TomographySnake
Segmentation directly from projections using deformable curve.

A collection of functions and scripts which produces slightly simplified figures used in
our paper
[Computing segmentations directly from x-ray projection data via parametric deformable curves](https://iopscience.iop.org/article/10.1088/1361-6501/aa950e/meta).


If you use our code in your research, please cite our paper.

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

To produce the different results shown in our paper, you will need to change the
values of the settings and comment/uncomment pieces of code as indicated in the comments.
Also check our paper to see which values are reasonable.

Comparison with SART and DART (Figure 13) requires
[ASTRA toolbox](https://www.astra-toolbox.com/).
For forward projections in Figures 14-16 we use
[AIRtools](http://www.imm.dtu.dk/~pcha/AIRtoolsII/index.html),
but with a little bit of tweaking (as explained in the
comments), `radon` function can be used instead.

![Figure 7](https://github.com/vedranaa/TomographySnake/blob/master/images/Figure7.png)
