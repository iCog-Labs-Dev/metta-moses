# MOSES -- Meta-Optimizing Semantic Evolutionary Search

This repository is contains re implementation of the Moses algorithm found in the [asmoses](https://github.com/opencog/asmoses) repository in MeTTa. A brief introduction about what the Moses algorithm can be found below.
## Introduction
MOSES is a machine-learning tool; it is an "evolutionary program learner". It is capable of learning short programs that capture patterns in input datasets. For a given data input, the programs will roughly recreate the dataset on which they were trained.

MOSES has been used in several commercial applications, including the analysis of medical physician and patient clinical data, and in several different financial systems. It is also used by OpenCog to learn automated behaviors, movements and actions in response to perceptual stimulus of artificial-life virtual agents (i.e. pet-dog game avatars). Future plans including using it to learn behavioral programs that control real-world robots, via the OpenPsi implementation of Psi-theory and ROS nodes running on the OpenCog AtomSpace.

The term "evolutionary" means that MOSES uses genetic programming techniques to "evolve" new programs. Each program can be thought of as a tree (similar to a "decision tree", but allowing intermediate nodes to be any programming-language construct). Evolution proceeds by selecting one exemplar tree from a collection of reasonably fit individuals, and then making random alterations to the program tree, in an attempt to find an even fitter (more accurate) program.

It is derived from the ideas formulated in Moshe Looks' PhD thesis, "Competent Program Evolution", 2006 (Washington University, Missouri). Moshe is also one of the primary authors of this code.

A short example, from beginning to end, can be found in this Jupyter notebook (courtesy Robert Haas, for the Mevis plot package.)

There is also a considerable amount of information in the OpenCog wiki: http://wiki.opencog.org/w/Meta-Optimizing_Semantic_Evolutionary_Search

## Running the code
- Make sure to install MeTTa `v0.1.12` following the instruction on the [hyperon-experimental](https://github.com/trueagi-io/hyperon-experimental) repository.
- For windows users, an alternative way of running MeTTa can be using the [metta-run](https://github.com/iCog-Labs-Dev/metta-prebuilt-binary) binary.

## Contributing
Before you start contributing to this repository, make sure to read the [CONTRIBUTING.md](https://github.com/iCog-Labs-Dev/metta-moses/tree/main/.github/CONTRIBUTING.md) file from our repository. 
