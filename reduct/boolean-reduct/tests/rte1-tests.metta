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


