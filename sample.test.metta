!(assertEqual 1 1)
!(== 1 1 )
!(let $truth (== 1 1) (
    assertEqual True (== 1 1)
))