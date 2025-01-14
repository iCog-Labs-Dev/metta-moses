(= (isEmpty $exp)
  (if (== Nil $exp) True False)
)

(= (max $first-val $second-val)
  (if (> $first-val $second-val) $first-val $second-val)
)

(= (checkTreeDepth $data)
  (case $data 
    (
      (($op $exp1 $exp2)
            (+ 1 (max (checkTreeDepth $exp1) (checkTreeDepth $exp2)))
      )
      (($op $exp1) 1)
      ($_ 0)
    )
  )
)

(= (nAryAnd $exp)
  (case $exp 
    (
      (Nil True)
      ((Cons $x $xs)
        (if (== $x True)
          (nAryAnd $xs)
          False
        )
      )
    )
  )
)

(= (nAryOr $exp)
  (case $exp 
    (
      (Nil False)
      ((Cons $x $xs)
        (if (== $x True)
          True
          (nAryOr $xs)
        )
      )
    )
  )
)

(: getChildren (-> Expression List List))
(= (getChildren $exp $guard-set)
  (if (==(get-metatype $exp) Symbol)
    Nil
    (if (==(get-metatype $exp) Expression)
      (case $exp 
        (
          ($op $exp1 $exp2)
          (let* 
            (
                ($type1 (get-metatype $exp1))
                ($type2 (get-metatype $exp2))
            )
            (if (and (== $type1 Symbol) (== $type2 Symbol))
              (append (Cons $exp1 (Cons $exp2 Nil)) $guard-set)

              (if (and (== $type1 Symbol) (== $type2 Expression))
                (append (Cons $exp1 Nil) (getChildren $exp2 $guard-set))

                (if (and (== $type1 Expression) (== $type2 Symbol))
                  (append (Cons $exp2 Nil) (getChildren $exp1 $guard-set))
                  (append (getChildren $exp1 $guard-set) (getChildren $exp2 $guard-set)) 
                )
              )
            )
          )
        )
      )
      (ERROR the format is invalid)
    )
  )
)

(: getGuardSet (-> Expression List List))
(= (getGuardSet $exp)
  (case $exp 
    (
      (
        ($OP $exp1 $exp2)
        (let* 
          (
            ($type1 (get-metatype $exp1))
            ($type2 (get-metatype $exp2)) 
          )
          (if (and (== $type1 Expression) (== $type2 Expression)) 
            Nil
            (if (== $OP AND)
              (if (and (== $type1 Symbol) (== $type2 Symbol))
                (Cons $exp1 (Cons $exp2 Nil))
                (if (and (== $type1 Symbol) (== $type2 Expression))
                  (Cons $exp1 Nil)
                  (Cons $exp2 Nil)
                )
              )
              Nil
            )
          )
        )
      )
      (
          ( $OP $exp )
          ( (if (== NOT $exp) ($OP $exp) ERROR) )
      )
      ($exp (Cons $exp Nil))
    )
  )
)