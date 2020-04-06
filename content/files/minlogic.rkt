#lang rosette/safe
(require rosette/lib/angelic
         rosette/lib/match)
(define (^^ x y) (|| (&& x (! y)) (&& (! x) y)))

(struct lnot (a)   #:transparent)
(struct land (a b) #:transparent)
(struct lor  (a b) #:transparent)
(struct lxor (a b) #:transparent)
(struct lvar (v)   #:transparent)
(struct llit (v)   #:transparent)

(define (ldump e)
  (match e
    [(lnot a)   `(! ,(ldump a))]
    [(land a b) `(&& ,(ldump a) ,(ldump b))]
    [(lor  a b) `(\|\| ,(ldump a) ,(ldump b))]
    [(lxor a b) `(^^ ,(ldump a) ,(ldump b))]
    [(lvar v) v]
    [(llit v) v]))

(define (leval e)
  (match e
    [(lnot a)   (!  (leval a))]
    [(land a b) (&& (leval a) (leval b))]
    [(lor  a b) (|| (leval a) (leval b))]
    [(lxor a b) (^^ (leval a) (leval b))]
    [(lvar v) v]
    [(llit v) v]))

(define (lcost e)
  (match e
    [(lnot a)   (+ 1 (lcost a))]
    [(land a b) (+ 2 (lcost a) (lcost b))]
    [(lor  a b) (+ 2 (lcost a) (lcost b))]
    [(lxor a b) (+ 2 (lcost a) (lcost b))]
    [(lvar v) 0]
    [(llit v) 1]))

(define (??lexpr terminals #:depth depth)
  (apply choose*
    (if (<= depth 0) terminals
    (let [(a (??lexpr terminals #:depth (- depth 1)))
          (b (??lexpr terminals #:depth (- depth 1)))]
      (append terminals
        (list (lnot a) (land a b) (lor a b) (lxor a b)))))))

(define (lmincost #:forall inputs #:tactic template #:equiv behavior)
  (define model
    (optimize
      #:minimize  (list (lcost template))
      #:guarantee (assert (forall inputs (equal? (leval template) behavior)))))
  (if (unsat? model) model
      (evaluate template model)))

(define-symbolic a b c boolean?)
(define f
  (lmincost
    #:forall (list a b c)
    #:tactic (??lexpr (list (lvar a) (lvar b) (lvar c) (llit #f)) #:depth 3)
    #:equiv  (&& (|| a (! (&& b c))) (! (&& a (|| (! b) (! c)))))))
(displayln (ldump f)) ; (! (^^ (&& c b) a))
