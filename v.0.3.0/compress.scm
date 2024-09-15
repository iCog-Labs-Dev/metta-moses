(define (compress-tree tree)
  (cond
    ;; If it's not a list (i.e., a leaf node like x1, x2, etc.), return it as is
    ((not (list? tree)) tree)
    
    ;; If it's an AND or OR node, process it
    ((and (list? (cdr tree))
          (or (eq? (car tree) 'AND)
              (eq? (car tree) 'OR)))
     (let ((operator (car tree)))
       (compress operator (cdr tree))))
    
    ;; Otherwise, return the tree as is
    (else tree)))

(define (compress operator args)
  (apply operator
         ;; Recursively compress the children and flatten if the same operator
         (fold-right (lambda (arg acc)
                       (let ((compressed-arg (compress-tree arg)))
                         (if (and (list? compressed-arg)
                                  (eq? (car compressed-arg) operator))
                             (append (cdr compressed-arg) acc)  ;; Flatten
                             (cons compressed-arg acc))))
                     '()
                     args)))

;; Example usage
(compress-tree '(AND (AND (AND x3 x4) x2) x1))
;; => (AND x3 x4 x2 x1)
