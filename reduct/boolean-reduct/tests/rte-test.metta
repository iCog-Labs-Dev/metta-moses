! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-and)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:promote-common-constraints)
! (import! &self metta-moses:reduct:boolean-reduct:reduce-to-elegance)

;; Tests for the component functions of the RTE algorithms.

;; Test for andTransformationNotApplied predicate function

!(assertEqual (transformationsNotApplied (() () (() () False))) True)
!(assertEqual (transformationsNotApplied (() () (() () True))) False)
!(assertEqual (transformationsNotApplied ((A B (NOT A)) () ((AND A B (OR C D)) (OR C D) True))) False)
!(assertEqual (transformationsNotApplied ((A B (NOT A)) () ((AND A B (OR C D)) (OR C D) False))) True)
!(assertEqual (transformationsNotApplied (() (A B (NOT A)) ((OR A B (AND C D)) (AND C D) True))) False)
!(assertEqual (transformationsNotApplied (() (A B (NOT A)) ((OR A B (AND C D)) (AND C D) False))) True)


;; Test for orTransformationNotApplied predicate function

!(assertEqual (transformationsNotApplied (() () (() () False))) True)
!(assertEqual (transformationsNotApplied (() () (() () True))) False)
!(assertEqual (transformationsNotApplied ((A B (NOT A)) () ((AND A B (OR C D)) (OR C D) True))) False)
!(assertEqual (transformationsNotApplied ((A B (NOT A)) () ((AND A B (OR C D)) (OR C D) False))) True)
!(assertEqual (transformationsNotApplied (() (A B (NOT A)) ((OR A B (AND C D)) (AND C D) True))) False)
!(assertEqual (transformationsNotApplied (() (A B (NOT A)) ((OR A B (AND C D)) (AND C D) False))) True)


;; Test for hasNoNextChild predicate function

!(assertEqual (hasNoNextChild ((AND A (OR A B) (OR C D) (OR E)) True ((OR A B) ((OR C D) (OR E))))) False)
!(assertEqual (hasNoNextChild ((AND A (OR A B) (OR C D) (OR E)) False ((OR C D) ((OR E))))) False)
!(assertEqual (hasNoNextChild ((AND A (OR A B) (OR C D)) False (() ()))) True)
!(assertEqual (hasNoNextChild ((AND A E (OR A B) (OR C D)) True (() ()))) True)
!(assertEqual (hasNoNextChild ((AND A (OR A B) (OR C D)) True (() ()))) True)
!(assertEqual (hasNoNextChild (() () ((AND A B) () False) ((OR A C) ()))) False)
!(assertEqual (hasNoNextChild ((A B) (C D) ((AND A B (OR C A) (OR A D) (OR E)) (OR C A) True) ((OR A D) (OR E)))) False)
!(assertEqual (hasNoNextChild (() () ((AND A (OR A B) (OR C D)) (OR A B) False) (() (AND A B)))) True)
!(assertEqual (hasNoNextChild (() () ((AND A (OR A B) (OR C D)) (OR A B) False) (() ()))) True)
!(assertEqual (hasNoNextChild (() () ((AND A (OR A B) (OR C D)) (OR C D) True) (() ()))) True)
!(assertEqual (hasNoNextChild (() () ((AND A E (OR A B) (OR C D)) (OR A B) True) (() ()))) True)

;; Test for applyAndTransformations function.

!(assertEqual (applyAndTransformations (() (C D) ((OR N O P (AND R X (NOT C)) V (AND Q S (OR T U)) W) (AND R X (NOT C)) False))) (() (C D) ((OR N O P V (AND Q S (OR T U)) W) () True)))
!(assertEqual (applyAndTransformations (() (A D) ((OR N O P (AND R X (NOT C)) V (AND (OR T U)) W) (AND (OR T U)) False))) (() (A D) ((OR N O P V W T U (AND R X (NOT C))) () True)))
!(assertEqual (applyAndTransformations (() (A D) ((OR N O P (AND R X (NOT C)) V (AND (OR T U (AND X Y) (AND Z B))) W) (AND (OR T U (AND X Y) (AND Z B))) False))) (() (A D) ((OR N O P V W T U (AND R X (NOT C)) (AND X Y) (AND Z B)) () True)))
!(assertEqual (applyAndTransformations (() (A D) ((OR N O P (AND R X (NOT C)) V (AND (OR T U)) W) (AND (OR T U)) False))) (() (A D) ((OR N O P V W T U (AND R X (NOT C))) () True)))
!(assertEqual (applyAndTransformations (() (A D) ((OR N O P (AND R X (NOT C)) V (AND (OR T U (AND X Y) (AND Z B))) W) (AND (OR T U (AND X Y) (AND Z B))) False))) (() (A D) ((OR N O P V W T U (AND R X (NOT C)) (AND X Y) (AND Z B)) () True)))
!(assertEqual (applyAndTransformations (() (A D) ((OR N O P (AND R X (NOT C)) V (AND (OR T U (AND U Y) (AND U B))) W) (OR T U (AND U Y) (AND U B)) False))) (() (A D) ((OR N O P (AND R X (NOT C)) V (AND (OR T U (AND U Y) (AND U B))) W) (OR T U (AND U Y) (AND U B)) False)))
!(assertEqual (applyAndTransformations (() (A D) ((OR N O P (AND R X (NOT C)) V (AND (OR T U (AND U Y) (AND U B))) W) (AND (OR T U (AND U Y) (AND U B))) False))) (() (A D) ((OR N O P (AND R X (NOT C)) V (AND U (OR T (AND Y) (AND B))) W) (AND U (OR T (AND Y) (AND B))) True)))
!(assertEqual (applyAndTransformations (() (A D) ((OR N O P (AND R X (NOT C)) V (AND (OR T U (AND U Y) (AND U B))) W) (AND (OR T U (AND Y) (AND D) (AND H I) (AND B))) False))) (() (A D) ((OR N O P V W T U (AND R X (NOT C)) (AND (OR T U (AND U Y) (AND U B))) (AND Y) (AND D) (AND H I) (AND B)) () True)))
!(assertEqual (applyAndTransformations (() () ((OR N O P (AND R X (NOT C)) V (AND Z (OR T (AND Y) (AND D) (AND H I) (AND B))) W) (AND Z (OR T U (AND Y) (AND D) (AND H I) (AND B))) False))) (() () ((OR N O P (AND R X (NOT C)) V (AND Z (OR T (AND Y) (AND D) (AND H I) (AND B))) W) (AND Z (OR T U (AND Y) (AND D) (AND H I) (AND B))) False)))

;; Test for applyOrTransformations function

!(assertEqual (applyOrTransformations (() () ((AND N O P (OR R X (NOT C)) V (OR Q S (AND T U)) W (OR Y)) (OR Y) False))) (() () ((AND N O P V W Y (OR R X (NOT C)) (OR Q S (AND T U))) () True)))
!(assertEqual (applyOrTransformations (() () ((AND A B (OR C D) (OR E F (AND G H) (AND I J (OR K L)) (AND))) (OR E F (AND G H) (AND I J (OR K L)) (AND)) False))) (() () ((AND A B (OR C D)) () True)))
!(assertEqual (applyOrTransformations (() () ((AND A B (OR C D) (OR E F (AND G H) (AND I J (OR K L)) (OR))) (OR E F (AND G H) (AND I J (OR K L)) (OR)) False))) (() () ((AND A B (OR C D)) () True)))
!(assertEqual (applyOrTransformations (() () ((AND N O P (OR R X (NOT C)) V (OR Q S (AND T U)) W) (OR R X (NOT C)) False))) (() () ((AND N O P (OR R X (NOT C)) V (OR Q S (AND T U)) W) (OR R X (NOT C)) False)))
!(assertEqual (applyOrTransformations (() () ((AND N O P (OR R X (NOT C)) V (OR Q S (AND T U)) W (OR (AND Y))) (OR (AND Y)) False))) (() () ((AND N O P V W (OR R X (NOT C)) (OR Q S (AND T U)) Y) () True)))
!(assertEqual (applyOrTransformations (() () ((AND N O P (OR R X (NOT C)) V (OR Q S (AND T U)) W (OR Y)) (OR Y) False))) (() () ((AND N O P V W Y (OR R X (NOT C)) (OR Q S (AND T U))) () True)))
!(assertEqual (applyOrTransformations (() () ((AND N O P (OR R X (NOT C)) V (OR Q S (AND T U)) W (OR Y (AND Z A))) (OR Y (AND Z A)) False))) (() () ((AND N O P (OR R X (NOT C)) V (OR Q S (AND T U)) W (OR Y (AND Z A))) (OR Y (AND Z A)) False)))
!(assertEqual (applyOrTransformations (() () ((AND N O P (OR R X (NOT C)) V (OR Q S (AND T U)) W (OR (AND Z A))) (OR (AND Z A)) False))) (() () ((AND N O P V W (OR R X (NOT C)) (OR Q S (AND T U)) Z A) () True)))
!(assertEqual (applyOrTransformations ((O X D) () ((AND N O P (OR R X (NOT C)) V (OR (AND T U)) W) (OR (AND T U)) False))) ((O X D) () ((AND N O P V W (OR R X (NOT C)) T U) () True)))
!(assertEqual (applyOrTransformations ((A D) () ((AND N O P (OR R X (NOT C)) V (OR (AND T U (OR X Y) (OR Z B))) W) (OR (AND T U (OR X Y) (OR Z B))) False))) ((A D) () ((AND N O P V W (OR R X (NOT C)) T U (OR X Y) (OR Z B)) () True)))
!(assertEqual (applyOrTransformations ((A D) () ((AND N O P (OR R X (NOT C)) V (OR (AND T U)) W) (OR (AND T U)) False))) ((A D) () ((AND N O P V W (OR R X (NOT C)) T U) () True)))
!(assertEqual (applyOrTransformations ((A D) () ((AND N O P (OR R X (NOT C)) V (OR (AND T U (OR X Y) (OR Z B))) W) (OR (AND T U (OR X Y) (OR Z B))) False))) ((A D) () ((AND N O P V W (OR R X (NOT C)) T U (OR X Y) (OR Z B)) () True)))
!(assertEqual (applyOrTransformations ((A D) () ((AND N O P (OR R X (NOT C)) V (OR (AND T U (OR U Y) (OR U B))) W) (AND T U (OR U Y) (OR U B)) False))) ((A D) () ((AND N O P (OR R X (NOT C)) V (OR (AND T U (OR U Y) (OR U B))) W) (AND T U (OR U Y) (OR U B)) False)))
!(assertEqual (applyOrTransformations (() (A D) ((AND N O P (OR R X (NOT C)) V (OR (AND T U (OR U Y) (OR U B))) W) (OR (AND T U (OR U Y) (OR U B))) False))) (() (A D) ((AND N O P V W (OR R X (NOT C)) T U (OR U Y) (OR U B)) () True)))
!(assertEqual (applyOrTransformations (() ()  ((AND E (OR A B (AND C D))) (OR A B (AND C D)) False))) (() () ((AND E (OR A B (AND C D))) (OR A B (AND C D)) False)))


;; Test for applyReduceToEleganceToAnd function

!(assertEqual (applyReduceToEleganceToAnd ((E) () ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) ((E) () ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() (E F) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) (() (E F) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() (J K) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) (() (J K) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() (E K) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) (() (E K) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() (F J) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) (() (F J) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() ((NOT E) F) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) (() ((NOT E) F) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() ((NOT E)) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) (() ((NOT E)) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() ((NOT F) J) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) (() ((NOT F) J) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() (F) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ()))) (() (F) ((AND A B (OR C D (AND E F)) (OR G H) (OR I)) (OR C D (AND E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd ((E) () ((OR A B (AND C D (OR E F)) (AND G H) (AND I)) (AND C D (OR E F)) False) (() ()))) ((E) () ((OR A B (AND C D (OR E F)) (AND G H) (AND I)) (AND C D (OR E F)) False) (() ())))
!(assertEqual (applyReduceToEleganceToAnd (() (E F) ((OR A B (AND C D (OR E F)) (AND G H) (AND I)) (AND C D (OR E F)) False) (() ()))) (() (E F) ((OR A B (AND C D (OR E F)) (AND G H) (AND I)) (AND C D (OR E F)) False) (() ())))

;; Test for applyReduceToEleganceToOr function

!(assertEqual (applyReduceToEleganceToOr ((E) () ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND E F) ((AND K L) (AND M J))))) ((E) () ((AND A B (OR C D (AND F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND F) (AND K L) (AND M J)) True) ((AND F) ((AND K L) (AND M J)))))
!(assertEqual (applyReduceToEleganceToOr (() ((NOT F)) ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND E F) ((AND K L) (AND M J))))) (() ((NOT F)) ((AND A B (OR C D (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND K L) (AND M J)) False) ((AND K L) ((AND M J)))))
!(assertEqual (applyReduceToEleganceToOr (() (E) ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND E F) ((AND K L) (AND M J))))) (() (E) ((AND A B (OR C D (AND F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND F) (AND K L) (AND M J)) True) ((AND F) ((AND K L) (AND M J)))))
!(assertEqual (applyReduceToEleganceToOr (() ((NOT E)) ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND E F) ((AND K L) (AND M J))))) (() ((NOT E)) ((AND A B (OR C D (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND K L) (AND M J)) False) ((AND K L) ((AND M J)))))
!(assertEqual (applyReduceToEleganceToOr ((K) () ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND K L) ((AND M J))))) ((K) () ((AND A B (OR C D (AND E F) (AND L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND L) (AND M J)) True) ((AND E F) ((AND L) (AND M J)))))
!(assertEqual (applyReduceToEleganceToOr (() ((NOT L)) ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND K L) ((AND M J))))) (() ((NOT L)) ((AND A B (OR C D (AND E F) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND M J)) False) ((AND M J) ())))
!(assertEqual (applyReduceToEleganceToOr ((K I) (J) ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND K L) ((AND M J))))) ((K I) (J) ((AND A B (OR C D (AND E F) (AND L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND L) (AND M J)) True) ((AND E F) ((AND L) (AND M J)))))
!(assertEqual (applyReduceToEleganceToOr ((K M) () ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND M J) ()))) ((K M) () ((AND A B (OR C D (AND E F) (AND K L) (AND J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND J)) True) ((AND E F) ((AND K L) (AND J)))))
!(assertEqual (applyReduceToEleganceToOr ((K M) ((NOT J)) ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND M J) ()))) ((K M) ((NOT J)) ((AND A B (OR C D (AND E F) (AND K L)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L)) True) ((AND E F) ((AND K L)))))
!(assertEqual (applyReduceToEleganceToOr ((K M) ((NOT M)) ((AND A B (OR C D (AND E F) (AND K L) (AND M J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND M J)) False) ((AND M J) ()))) ((K M) ((NOT M)) ((AND A B (OR C D (AND E F) (AND K L) (AND J)) (OR G H) (OR I)) (OR C D (AND E F) (AND K L) (AND J)) True) ((AND E F) ((AND K L) (AND J)))))
!(assertEqual (applyReduceToEleganceToOr ((K M) ((NOT M)) ((OR A B (AND C D (OR E F) (OR K L) (OR M J)) (AND G H) (AND I)) (AND C D (OR E F) (OR K L) (OR M J)) False) ((OR M J) ()))) ((K M) ((NOT M)) ((OR A B (AND C D (OR E F) (OR K L) (OR M J)) (AND G H) (AND I)) (AND C D (OR E F) (OR K L) (OR M J)) False) (() ())))
!(assertEqual (applyReduceToEleganceToOr ((K M) ((NOT M)) ((OR A B (AND C D (OR E F) (OR K L) (OR M J)) (AND G H) (AND I)) (AND C D (OR E F) (OR K L) (OR M J)) False) ((OR M J) ()))) ((K M) ((NOT M)) ((OR A B (AND C D (OR E F) (OR K L) (OR M J)) (AND G H) (AND I)) (AND C D (OR E F) (OR K L) (OR M J)) False) (() ())))


;; Test for localCommandSet function

!(assertEqual (localCommandSet () () (A B C) (D)) (A B C D))
!(assertEqual (localCommandSet () () (A B C) ()) (A B C))
!(assertEqual (localCommandSet (AND I (OR A B)) ((AND A B (OR C D)) (AND E F) (AND G) (AND H) (AND I (OR A B))) (J K L) (M)) (J K L G H M))
!(assertEqual (localCommandSet (AND E F) ((AND A B (OR C D)) (AND E F) (AND G) (AND H) (AND I (OR A B))) (J K L) (M)) (J K L G H M))
!(assertEqual (localCommandSet (AND G) ((AND A B (OR C D)) (AND E F) (AND G) (AND H) (AND I (OR A B))) (J K L) (M)) (J K L H M))
!(assertEqual (localCommandSet (AND I (OR A B)) ((AND A B (OR C D)) (AND E F) (AND G) (AND H) (AND I (OR A B))) (J K L) (M)) (J K L G H M))
!(assertEqual (localCommandSet (OR I (AND A B)) ((OR A B (AND C D)) (OR E F) (OR G) (OR H) (OR I (AND A B))) (J K L) (M)) (J K L M))
!(assertEqual (localCommandSet (OR E F) ((OR A B (AND  C D)) (OR E F) (OR G) (OR H) (OR I (AND A B))) (J K L) (M)) (J K L M))
!(assertEqual (localCommandSet (OR G) ((OR A B (AND C D)) (OR E F) (OR G) (OR H) (OR I (AND A B))) (J K L) (M)) (J K L M))
!(assertEqual (localCommandSet (OR I (AND A B)) ((OR A B (AND C D)) (OR E F) (OR G) (OR H) (OR I (AND A B))) (J K L) (M)) (J K L M))

================================
;; Test for filterTerminal function

!(assertEqualToResult (filterTerminalAndNode (AND A)) ((AND A)))
!(assertEqualToResult (filterTerminalAndNode (AND (NOT A))) ((AND (NOT A))))
!(assertEqualToResult (filterTerminalAndNode (AND A B (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND A (NOT B) (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND A (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND (NOT A) (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND (OR A B) (OR C D))) ())
!(assertEqualToResult (filterTerminalAndNode (AND)) ())
!(assertEqualToResult (filterTerminalAndNode (OR A)) ())
!(assertEqualToResult (filterTerminalAndNode (OR (NOT A))) ())
!(assertEqualToResult (filterTerminalAndNode (OR A B (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR A (NOT B) (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR A (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR (NOT A) (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR (AND A B) (AND C D))) ())
!(assertEqualToResult (filterTerminalAndNode (OR)) ())

;; Test for applyOrCut function

!(assertEqual (applyOrCut ((AND A (OR A) (OR A B) (OR C D) (OR E)) False ((OR A) ((OR A B) (OR C D) (OR E))))) ((AND A (OR A B) (OR C D) (OR E)) True ((OR A B) ((OR C D) (OR E)))))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D) (OR E)) False ((OR A B) ((OR C D) (OR E))))) ((AND A (OR A B) (OR C D) (OR E)) False ((OR C D) ((OR E)))))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D) (OR E)) False ((OR E) ()))) ((AND A E (OR A B) (OR C D)) True (() ())))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D)) False (() ()))) ((AND A (OR A B) (OR C D)) False (() ())))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D)) True (() ()))) ((AND A (OR A B) (OR C D)) True (() ())))


;; Test for RTE transformations functions
;; Delete Inconsistent Handle Test
!(assertEqual (reduceToElegance (AND A (OR (AND B) (AND (NOT A) (OR (AND B) (AND C))))) (OR (AND B) (AND (NOT A) (OR (AND B) (AND C)))) (A) (B)) ((AND A ) () False))

;; Promote Common Constraints Test
!(assertEqual (reduceToElegance (AND A (OR (AND (NOT B) C) (AND (NOT B))) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) (OR (AND (NOT B) C) (AND (NOT B))) (A) ()) ((AND A (NOT B) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) () True))

;; Subtract Redundant Test
!(assertEqual (reduceToElegance (OR (AND A) (AND A C (NOT D))) (AND A C (NOT D)) ((NOT B) C A) (A (NOT E))) ((OR (AND A) (AND (NOT D))) (AND (NOT D)) True))

;; Cut unnecessary OR Test
!(assertEqual (reduceToElegance (AND B (OR (AND (NOT D)))) (OR (AND (NOT D))) (A B) ()) ((AND B (NOT D)) () True))

;; Cut unnecessary AND Test
!(assertEqual (reduceToElegance (OR (AND C) (AND (OR (AND (NOT E)) (AND B D)))) (AND (OR (AND (NOT E)) (AND B D))) (A) (C)) ((OR (AND C) (AND (NOT E)) (AND B D)) () False))

;; 0-Constraint Subsumption Test
!(assertEqual (reduceToElegance (AND A (OR (AND A) (AND (NOT B) (OR (AND E) (AND F)))) (OR (AND C) (AND))) (OR (AND C) (AND)) (A) ()) ((AND A (OR (AND A) (AND (NOT B) (OR (AND E) (AND F))))) () False))

;; 1-Constraint Subsumption Test
!(assertEqual (reduceToElegance (OR (AND C) (AND E D)) (AND E D) (A B) (C D)) ((OR (AND C) (AND E)) (AND E) True))

;; 1-Constraint Complement Subtraction Test
!(assertEqual (reduceToElegance (OR (AND D) (AND B C)) (AND B C) (A B) (D (NOT B))) ((OR (AND D) (AND C)) (AND C) True))

=========================================
;; Test cases from python implementation.

!(assertEqual (reduceToElegance (AND (NOT A)) (NOT A) () ()) ((AND (NOT A)) (NOT A) False))
;
;; (AND (OR (NOT A) (NOT B))) ==> (AND (OR (NOT A ) (NOT B)))
!(assertEqual (reduceToElegance (AND (OR (NOT A) (NOT B))) (OR (NOT A) (NOT B)) () ()) ((AND (OR (NOT A) (NOT B))) (OR (NOT A) (NOT B)) False))
;; (AND (NOT A) (NOT B)) ==> (AND (NOT A) (NOT B))
!(assertEqual (reduceToElegance (AND (AND (NOT A) (NOT B))) (AND (NOT A) (NOT B)) () ()) ((AND (AND (NOT A) (NOT B))) (AND (NOT A) (NOT B)) False))
;; (AND A B) ==> (AND A B)
!(assertEqual (reduceToElegance (AND (AND A B)) (AND A B) () ()) ((AND (AND A B)) (AND A B) False))
;; (AND (OR A B)) ==> (AND (OR A B))
!(assertEqual (reduceToElegance (AND (OR A B)) (OR A B) () ()) ((AND (OR A B)) (OR A B) False))
;; (AND (OR (AND (NOT A) (NOT B)) (NOT C) (NOT D))) ==> (AND (OR (AND (NOT A) (NOT B)) (NOT C) (NOT D)))
!(assertEqual (reduceToElegance (AND (OR (AND (NOT A) (NOT B)) (NOT C) (NOT D))) (OR (AND (NOT A) (NOT B)) (NOT C) (NOT D)) () ()) ((AND (NOT A) (NOT B)) () True))
;; (AND (A A)) ==> (AND (A A))
!(assertEqual (reduceToElegance (AND (AND (A A))) (AND (A A)) () ()) ((AND A) () False))
;; (AND A A C) ==> (AND A A C)
!(assertEqual (reduceToElegance (AND (AND A A C)) (AND A A C) () ()) ((AND (AND A A C)) (AND A A C) False))
;; (AND A B (OR C D)) ==> (AND A B (OR C D))
!(assertEqual (reduceToElegance (AND (AND A B (OR C D))) (AND A B (OR C D)) () ()) ((AND (AND A B (OR C D))) (AND A B (OR C D)) False))
;; (AND A B C D C) ==> (AND A B C D C)
!(assertEqual (reduceToElegance (AND (AND A B C D C)) (AND A B C D C) () ()) ((AND (AND A B C D C)) (AND A B C D C) False))
;; (AND A (OR B (AND C (OR D E A)))) ==> (AND A (OR B C))
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A))))) () ()) ((AND (AND A (OR (AND B) (AND C)))) (AND A (OR (AND B) (AND C))) False))
;; (AND (NOT A) (NOT C) B (OR B (NOT A))) ==> (AND (NOT A) (NOT C) B)
!(assertEqual (reduceToElegance (AND (AND (NOT A) (NOT C) B (OR B (NOT A)))) (AND (NOT A) (NOT C) B (OR B (NOT A))) () ()) ((AND (AND (NOT A) (NOT C) B (OR B (NOT A)))) (AND (NOT A) (NOT C) B (OR B (NOT A))) False))
;; (AND A (OR B (AND C (OR D (AND E (NOT A)))))) ==> (AND A (OR B (AND C D)))
!(assertEqual (reduceToElegance (AND (AND A (OR B (AND C (OR D (AND E (NOT A))))))) (AND A (OR B (AND C (OR D (AND E (NOT A)))))) () ()) ((AND) () False))
;; (AND A B A A A) ==> (AND A B A A A)
!(assertEqual (reduceToElegance (AND (AND A B A A A)) (AND A B A A A) () ()) ((AND (AND A B A A A)) (AND A B A A A) False))
=====================================
;; (AND A B C D (NOT B)) ==> (AND)
!(assertEqual (reduceToElegance (AND (AND A B C D (NOT B))) (AND A B C D (NOT B)) () ()) ((AND) () False))
;; (AND B (NOT C) (NOT A) (OR B (NOT A))) ==> (AND B (NOT C) (NOT A))
!(assertEqual (reduceToElegance (AND (AND B (NOT C) (NOT A) (OR B (NOT A)))) (AND B (NOT C) (NOT A) (OR B (NOT A))) () ()) ((AND (AND B (NOT C) (NOT A) (OR B (NOT A)))) (AND B (NOT C) (NOT A) (OR B (NOT A))) False))
;; (AND B (NOT C) (NOT A) (OR B (AND (NOT K) (NOT X)))) ==> (AND B (NOT C) (NOT A))
!(assertEqual (reduceToElegance (AND (AND B (NOT C) (NOT A) (OR (AND B) (AND (NOT K) (NOT X))))) (AND B (NOT C) (NOT A) (OR (AND B) (AND (NOT K) (NOT X)))) () ()) ((AND (AND B (NOT C) (NOT A))) (AND B (NOT C) (NOT A)) False))
;; (AND (NOT A) (NOT C) B (OR (NOT B) (NOT A))) ==> (AND (NOT A) (NOT C) B)
!(assertEqual (reduceToElegance (AND (AND (NOT A) (NOT C) B (OR (AND (NOT B)) (AND (NOT A))))) (AND (NOT A) (NOT C) B (OR (AND (NOT B)) (AND (NOT A)))) () ()) ((AND (AND (NOT A) (NOT C) B)) (AND (NOT A) (NOT C) B) False))
;; (AND B (NOT C) (NOT A) (OR (NOT B) (NOT C) (NOT D) (NOT A))) ==> (AND B (NOT C) (NOT A))
!(assertEqual (reduceToElegance (AND (AND B (NOT C) (NOT A) (OR (NOT B) (NOT C) (NOT D) (NOT A)))) (AND B (NOT C) (NOT A) (OR (NOT B) (NOT C) (NOT D) (NOT A))) () ()) ((AND (AND B (NOT C) (NOT A) (OR (NOT B) (NOT C) (NOT D) (NOT A)))) (AND B (NOT C) (NOT A) (OR (NOT B) (NOT C) (NOT D) (NOT A))) False))
;; (AND A B C B A A (NOT A) (OR A B C A)) ==> (AND)
!(assertEqual (reduceToElegance (AND (AND A B C B A A (NOT A) (OR A B C A))) (AND A B C B A A (NOT A) (OR A B C A)) () ()) ((AND) () False))
;; (AND (OR A B)) ==> (AND (OR A B))
!(assertEqual (reduceToElegance (AND (OR A B)) (OR A B) () ()) ((AND (OR A B)) (OR A B) False))
;; (AND (OR A A)) ==> (AND A)
!(assertEqual (reduceToElegance (AND (OR A A)) (OR A A) () ()) ((AND (OR A A)) (OR A A) False)) ;; ((AND A) () False)
;; (AND (OR (AND A B) A C)) ==> (AND (OR (AND A B) A C))
!(assertEqual (reduceToElegance (AND (OR (AND A B) A C)) (OR (AND A B) A C) () ()) ((AND A B) () True))
;; (AND (OR (AND A B) (AND A B))) ==> (AND A B)
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A B))) (OR (AND A B) (AND A B)) () ()) ((AND A B) () True))
;; (AND (OR (AND A B) C D)) ==> (AND (OR (AND A B) C D))
!(assertEqual (reduceToElegance (AND (OR (AND A B) C D)) (OR (AND A B) C D) () ()) ((AND A B) () True))
;; (AND (OR (NOT A) (NOT C) (NOT D))) ==> (AND (OR (NOT A) (NOT C) (NOT D)))
!(assertEqual (reduceToElegance (AND (OR (NOT A) (NOT C) (NOT D))) (OR (NOT A) (NOT C) (NOT D)) () ()) ((AND (OR (NOT A) (NOT C) (NOT D))) (OR (NOT A) (NOT C) (NOT D)) False))
;; (AND (OR (AND A (OR (NOT B) (NOT C))) D)) ==> (AND (OR (AND A (OR (NOT B) (NOT C))) D))
!(assertEqual (reduceToElegance (AND (OR (AND A (OR (NOT B) (NOT C))) D)) (OR (AND A (OR (NOT B) (NOT C))) D) () ()) ((AND A (OR D (NOT B) (NOT C))) (OR D (NOT B) (NOT C)) True))
;; (AND (OR A B C D C)) ==> (AND (OR A B C D C))
!(assertEqual (reduceToElegance (AND (OR A B C D C)) (OR A B C D C) () ()) ((AND (OR A B C D C)) (OR A B C D C) False))
;; (AND (OR A (AND B C D C))) ==> (AND (OR A (AND B C D C)))
!(assertEqual (reduceToElegance (AND (OR A (AND B C D C))) (OR A (AND B C D C)) () ()) ((AND B C D) () True))
;; (AND (OR (NOT C) (NOT D) (AND (NOT A) B))) ==> (AND (OR (NOT C) (NOT D) (AND (NOT A) B)))
!(assertEqual (reduceToElegance (AND (OR (NOT C) (NOT D) (AND (NOT A) B))) (OR (NOT C) (NOT D) (AND (NOT A) B)) () ()) ((AND (NOT A) B) () True))
;; (AND (OR A B C D (NOT C))) ==> (AND (OR A B C D (NOT C)))
!(assertEqual (reduceToElegance (AND (OR A B C D (NOT C))) (OR A B C D (NOT C)) () ()) ((AND (OR A B C D (NOT C))) (OR A B C D (NOT C)) False))
;; (AND (OR (AND A B) (AND A C) (AND A D))) ==> (AND A (OR B C D))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C) (AND A D))) (OR (AND A B) (AND A C) (AND A D)) () ()) ((AND A (OR (AND B) (AND C) (AND D))) (OR (AND B) (AND C) (AND D)) True))
;; (AND (OR (AND A B) (AND A C (OR D (AND E A))))) ==> (AND A (OR B (AND C (OR D E))))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E A))))) (OR (AND A B) (AND A C (OR (AND D) (AND E A)))) () ()) ((AND A (OR (AND B) (AND C (OR (AND D) (AND E A))))) (OR (AND B) (AND C (OR (AND D) (AND E A)))) True))  ;; INFO: This test case fails bec(reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND A))))) (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND A)))) () ())uase RTE needs to be called again if the parent chang ed
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E A)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E A))))) () ()) ((AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E))))) False))
=========================================================
;; (AND (OR (AND A B) (AND A C (OR D E A)))) ==> (AND A (OR B C))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND A))))) (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND A)))) () ())  ((AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A))))) (OR (AND B) (AND C (OR (AND D) (AND E) (AND A)))) True))
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND A))))) () ()) ((AND (AND A (OR (AND B) (AND C)))) (AND A (OR (AND B) (AND C))) False))
;; (AND (OR (AND A B) (AND A C (OR D E (NOT A))))) ==> (AND A (OR B (AND C (OR D E))))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND (NOT A)))))) (OR (AND A B) (AND A C (OR (AND D) (AND E) (AND (NOT A))))) () ()) ((AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A)))))) (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A))))) True))  ;; INFO: This test case fails becuase RTE needs to be called again if the parent chang ed
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A))))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E) (AND (NOT A)))))) () ()) ((AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E)))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E))))) False))
;; (AND (OR (AND A B) (AND A C (OR D (AND E (NOT A)))))) ==> (AND A (OR B (AND C D)))
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A))))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) () ()) ((AND (AND A (OR (AND B) (AND C D)))) (AND A (OR (AND B) (AND C D))) False))
;; (AND (OR (AND A B) (AND A C (OR D (AND E (NOT A)))))) ==> (AND A (OR B (AND C D)))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C (OR (AND D) (AND E (NOT A)))))) (OR (AND A B) (AND A C (OR (AND D) (AND E (NOT A))))) () ()) ((AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) (OR (AND B) (AND C (OR (AND D) (AND E (NOT A))))) True))   ;; INFO: This test case fails becuase RTE needs to be called again if the parent chang ed
!(assertEqual (reduceToElegance (AND (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A))))))) (AND A (OR (AND B) (AND C (OR (AND D) (AND E (NOT A)))))) () ()) ((AND (AND A (OR (AND B) (AND C D)))) (AND A (OR (AND B) (AND C D))) False))
============================================
;; (AND (OR (NOT A) (AND A B C) (AND B C (NOT B)))) ==> (AND (OR (NOT A) (AND A B C)))
!(assertEqual (reduceToElegance (AND (OR (AND (NOT A)) (AND A B C) (AND B C (NOT B)))) (OR (AND (NOT A)) (AND A B C) (AND B C (NOT B))) () ()) ((AND (OR (AND (NOT A)) (AND A B C))) (OR (AND (NOT A)) (AND A B C)) False))
;; (AND (OR (NOT A) (AND A B C) (AND B C (NOT B)))) ==> (AND (OR (NOT A) (AND A B C)))
!(assertEqual (reduceToElegance (AND (OR (NOT A) (AND A B C) (AND B C (NOT B)))) (OR (NOT A) (AND A B C) (AND B C (NOT B))) () ()) ((AND B C (OR (NOT A) (AND A) (AND (NOT B)))) (OR (NOT A) (AND A) (AND (NOT B))) True))
;; (AND (OR (NOT A) (AND A B C) (AND C B (NOT B)))) ==> (AND (OR (NOT A ) (AND A B C)))
!(assertEqual (reduceToElegance (AND (OR (NOT A) (AND A B C) (AND C B (NOT B)))) (OR (NOT A) (AND A B C) (AND C B (NOT B))) () ()) ((AND B C (OR (NOT A) (AND A) (AND (NOT B)))) (OR (NOT A) (AND A) (AND (NOT B))) True))
;; (AND (OR (AND C A D) (AND C A) (AND C A E))) ==> (AND C A)
!(assertEqual (reduceToElegance (AND (OR (AND C A D) (AND C A) (AND C A E))) (OR (AND C A D) (AND C A) (AND C A E)) () ()) ((AND C A) () True))
;; (AND (OR (AND A B) (AND A C D) (AND A C E) (AND C A))) ==> (AND A (OR B (AND C D) (AND C E) C))
!(assertEqual (reduceToElegance (AND (OR (AND A B) (AND A C D) (AND A C E) (AND C A))) (OR (AND A B) (AND A C D) (AND A C E) (AND C A)) () ()) ((AND A (OR (AND B) (AND C D) (AND C E) (AND C))) (OR (AND B) (AND C D) (AND C E) (AND C)) True))
==========================================
;; Test 04: Test case from Mosh's paper. Page 37

;; (AND (OR G (AND A B (OR (NOT C) (NOT D) E) (OR C (AND C F))))) ==> (AND (OR G (AND A B C (OR (NOT D) E))))
!(assertEqual (reduceToElegance (AND (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F))))) (OR (AND G) (AND A B (OR (AND (NOT C)) (AND (NOT D)) (AND E)) (OR (AND C) (AND C F)))) () ()) ((AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) False))
;; (AND (OR G (AND A B C (OR (NOT D) E)))) ==> (AND (OR G (AND A B C (OR (NOT D) E))))
!(assertEqual (reduceToElegance (AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) () ()) ((AND (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E))))) (OR (AND G) (AND A B C (OR (AND (NOT D)) (AND E)))) False))
!(assertEqual (reduceToElegance (AND E (OR (AND A) (AND B) (AND C D))) (OR (AND A) (AND B) (AND C D)) () ()) ((AND E (OR (AND A) (AND B) (AND C D))) (OR (AND A) (AND B) (AND C D)) False))
!(assertEqual (reduceToElegance (OR (AND A) (AND B) (AND C D)) (AND C D) () ()) ((OR (AND A) (AND B) (AND C D)) (AND C D) False))
