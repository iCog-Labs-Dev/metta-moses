;; ================================================================================
;; EDA Framework - Main Module
;; ================================================================================
;;
;; This file serves as the main EDA module that imports all EDA components.
;; Equivalent to the main EDA orchestration in optimize.h in the C++ implementation.
;;
;; This module provides a unified interface to all EDA components:
;; - Parameters management
;; - Structure learning
;; - Probability learning
;; - Selection policies
;; - Replacement strategies
;; - Model sampling
;; - Termination criteria
;; - Initialization policies
;;
;; Usage:
;; - Import this module to get access to all EDA functionality
;; - Use individual components as needed
;; - Follow the C++ EDA workflow: selection → model learning → sampling → replacement

;; ================================================================================
;; Module Imports
;; ================================================================================

!(import! &self metta-moses:optimization:eda:eda-parameters)
!(import! &self metta-moses:optimization:eda:local-structure)
!(import! &self metta-moses:optimization:eda:probability-learning)
!(import! &self metta-moses:optimization:eda:selection)
!(import! &self metta-moses:optimization:eda:replacement)
!(import! &self metta-moses:optimization:eda:sampling)
!(import! &self metta-moses:optimization:eda:termination)
!(import! &self metta-moses:optimization:eda:initialization)

;; ================================================================================
;; EDA Framework Documentation
;; ================================================================================

;; The EDA (Estimation of Distribution Algorithm) framework provides:
;;
;; 1. **Parameters Management** (eda-parameters.metta):
;;    - EDAParameters type and default values
;;    - Parameter access functions
;;
;; 2. **Structure Learning** (local-structure.metta):
;;    - Univariate structure learning (no dependencies)
;;    - Placeholder for multivariate structure learning
;;
;; 3. **Probability Learning** (probability-learning.metta):
;;    - Learn probability distributions from selected instances
;;    - Laplace smoothing and normalization
;;    - KnobProbabilityModel data structure
;;
;; 4. **Selection Policies** (selection.metta):
;;    - Tournament selection
;;    - Random K selection
;;    - Best individual selection
;;
;; 5. **Replacement Strategies** (replacement.metta):
;;    - Replace worst instances with new ones
;;    - Sort instances by score
;;    - Maintain population size
;;
;; 6. **Model Sampling** (sampling.metta):
;;    - Sample new instances from learned models
;;    - Generate instances from probability distributions
;;    - Create instances compatible with representation
;;
;; 7. **Termination Criteria** (termination.metta):
;;    - Score-based termination
;;    - No improvement termination
;;    - Best score extraction
;;
;; 8. **Initialization Policies** (initialization.metta):
;;    - Uniform random initialization
;;    - Sample instances from representation
;;    - Create diverse initial populations
;;
;; ================================================================================
;; EDA Workflow
;; ================================================================================

;; The standard EDA workflow follows this pattern:
;;
;; 1. **Initialize** population using initialization policies
;; 2. **Select** promising individuals using selection policies
;; 3. **Learn** probability model from selected individuals
;; 4. **Sample** new individuals from learned model
;; 5. **Replace** worst individuals with new ones
;; 6. **Check** termination criteria
;; 7. **Repeat** until termination
;;
;; Example usage:
;; ```
;; ;; Initialize population
;; (sample-uniform-instance $rep)
;;
;; ;; Select promising individuals
;; (tournament-selection $tournamentSize $deme $nSelect)
;;
;; ;; Learn probability model
;; (learn-probability-model $deme $selectedInstances)
;;
;; ;; Sample new individuals
;; (sample-from-model $probModel $deme $nGenerate)
;;
;; ;; Replace worst individuals
;; (replace-the-worst $newInstances $deme)
;;
;; ;; Check termination
;; (terminate-if-gte-or-no-improv $threshold $maxGens $deme)
;; ```

;; ================================================================================
;; Compatibility Notes
;; ================================================================================

;; This EDA framework is designed to be compatible with:
;; - The C++ EDA implementation in asmoses
;; - The MOSES optimization framework
;; - The univariate optimizer implementation
;; - Future multivariate EDA implementations
;;
;; The modular design allows for easy extension and modification
;; of individual components without affecting the overall framework.
