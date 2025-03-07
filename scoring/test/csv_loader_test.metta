! (register-module! ../../../metta-moses)
! (import! &self metta-moses:scoring:csv-preprocessor)

!(bind! &test_space (new-space))

;The Loader Takes as an Input $t which is the location of the csv file that is going to be loaded and $y is the space name that is created above
; it takes $t and $y as an argument and calls the load_csv function then add the converted csv files to the new created space which is $y
;Note that when passing the space name dont forget to add & at the beggining of your new space name.

(=(Loader $t $y) (let $x (load_csv $t) (add-atom $y $x)))

;Make sure The csv file has a format of A,B,C,D,.....,TruthValue
!(Loader test_csv_files/truth.csv &test_space)

; Test Case
!(assertEqual
    (match &test_space ($truth-val ($A $T1)($B $T2)($C $T3)($D $T4)) ($truth-val ($A $T1)($B $T2)($C $T3)($D $T4)))
    (match &test_space $x $x)
)

!(match &test_space $x $x)
!(match &test_space (True $x $Y $c $v ) ($v))

