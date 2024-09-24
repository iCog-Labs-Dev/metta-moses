
(= (reduceToElegance $expr)
    (let*
    (
      ($trnsformationOne (inconHandle $expr))
      ($trnsformationTwo (promote $trnsformationOne))
      ($trnsformationThree (orCut $trnsformationTwo))
      ($trnsformationFour (andCut $trnsformationThree))
      ($trnsformationFive (redundant $trnsformationFour))
      ($trnsformationSix (oSubsume $trnsformationFive))
      ($trnsformationSeven (oneSubsume $trnsformationSix))
      ($trnsformationEight (oneCCSubtract $trnsformationSeven))
    )
      ($trnsformationEight)
     )
)