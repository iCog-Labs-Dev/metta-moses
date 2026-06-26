# MOSES -- Meta-Optimizing Semantic Evolutionary Search

This repository is contains re implementation of the Moses algorithm found in the [asmoses](https://github.com/opencog/asmoses) repository in MeTTaLog. A brief introduction about what the Moses algorithm can be found below.

## Introduction

MOSES is a machine-learning tool; it is an "evolutionary program learner". It is capable of learning short programs that capture patterns in input datasets. For a given data input, the programs will roughly recreate the dataset on which they were trained.

MOSES has been used in several commercial applications, including the analysis of medical physician and patient clinical data, and in several different financial systems. It is also used by OpenCog to learn automated behaviors, movements and actions in response to perceptual stimulus of artificial-life virtual agents (i.e. pet-dog game avatars). Future plans including using it to learn behavioral programs that control real-world robots, via the OpenPsi implementation of Psi-theory and ROS nodes running on the OpenCog AtomSpace.

The term "evolutionary" means that MOSES uses genetic programming techniques to "evolve" new programs. Each program can be thought of as a tree (similar to a "decision tree", but allowing intermediate nodes to be any programming-language construct). Evolution proceeds by selecting one exemplar tree from a collection of reasonably fit individuals, and then making random alterations to the program tree, in an attempt to find an even fitter (more accurate) program.

It is derived from the ideas formulated in Moshe Looks' PhD thesis, "Competent Program Evolution", 2006 (Washington University, Missouri). Moshe is also one of the primary authors of this code.

A short example, from beginning to end, can be found in this Jupyter notebook (courtesy Robert Haas, for the Mevis plot package.)

There is also a considerable amount of information in the OpenCog wiki: <http://wiki.opencog.org/w/Meta-Optimizing_Semantic_Evolutionary_Search>

## Running the code

Install PeTTa first by following the instructions in the
[PeTTa](https://github.com/trueagi-io/PeTTa) repository, then clone this
repo and `cd` into it.

### Quick start

The repo root has a single entry file, `moses.metta`. It wires up every
module the pipeline needs, applies any `--name=value` flags you pass on
the command line, and runs MOSES. You just point PeTTa at it:

```sh
./PeTTa/run.sh moses.metta -s --problem=parity3
```

That's a complete run — solve the 3-bit parity problem with default
settings (20 generations, 1 deme, hill-climbing optimizer, no feature
selection).

### hyperparameters

`--help` prints every registered hyperparameter together with its
current value:

```sh
./PeTTa/run.sh moses.metta -s --help
```

Every value shown by `--help` can be overridden with `--name=value`.
A few common ones:

```sh
./PeTTa/run.sh moses.metta -s \
    --problem=mux3 \           # which problem to solve (parity3, parity4, majority3, majority5, mux3, mux6, disjunction3, …)
    --maxGen=30 \              # max generations
    --nDeme=2 \                # number of demes per expansion
    --fsAlgo=smd \             # feature-selection algorithm (None | smd | sim | inc | rd | mi | hc)
    --optAlgo=hc \             # optimizer (currently only hc; sa / univariate are stubs)
    --capCoef=80 \             # metapopulation cap coefficient
    --complexityRatio=2.5 \    # complexity/fitness trade-off
    --hcMaxEvals=20000         # per-iteration hill-climbing eval budget
```

Flags can appear in any order; unrecognized ones are ignored.

If you run `./PeTTa/run.sh moses.metta -s` with **no** `--problem` (or
without an in-script `(set-param problem …)`), MOSES prints the help and
exits rather than silently running a default problem.

### Running the test suite

```sh
python3 scripts/run-tests.py
```

Discovers every `*test.metta` file under the tree and runs them in
parallel via PeTTa.

## Contributing

Before you start contributing to this repository, make sure to read the [CONTRIBUTING.md](https://github.com/iCog-Labs-Dev/metta-moses/tree/main/.github/CONTRIBUTING.md) file from our repository.
