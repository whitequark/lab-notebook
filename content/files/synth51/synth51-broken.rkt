#lang rosette/safe

(require (only-in racket hash in-range for))
(require rosette/solver/smt/z3
         rosette/solver/smt/boolector
         rosette/solver/smt/yices)
; (current-solver
;  (z3
;   #:logic 'QF_BV
;   #:options (hash
;    ':parallel.enable 'true
;    ':parallel.threads.max 4)))

(require rosette/lib/angelic
         rosette/lib/match)

; bit operations
(define (rotate-right s i x)
  (cond
    [(= i 0) x]
    [else (concat (extract (- i 1) 0 x) (extract (- s 1) i x))]))
(define (rotate-left s i x)
  (cond
    [(= i 0) x]
    [else (concat (extract (- s i 1) 0 x) (extract (- s 1) (- s i) x))]))

(define (replace-bit s i x y)
  (define m (bvshl (bv 1 s) (integer->bitvector i s)))
  (cond
    [(bveq y (bv 0 1)) (bvand x (bvnot m))]
    [(bveq y (bv 1 1)) (bvor x m)]
    [else (assert #f)]))

; CPU state
(struct state (A C Rn) #:mutable #:transparent)

(define (state-Rn-ref S n)
  (vector-ref (state-Rn S) n))
(define (state-Rn-set! S n v)
  (vector-set! (state-Rn S) n v))
(define (state-R0 S) (state-Rn-ref S 0))
(define (state-R1 S) (state-Rn-ref S 1))
(define (state-R2 S) (state-Rn-ref S 2))
(define (state-R3 S) (state-Rn-ref S 3))
(define (state-R4 S) (state-Rn-ref S 4))
(define (state-R5 S) (state-Rn-ref S 5))
(define (state-R6 S) (state-Rn-ref S 6))
(define (state-R7 S) (state-Rn-ref S 7))

(define-symbolic A R0 R1 R2 R3 R4 R5 R6 R7 (bitvector 8))
(define-symbolic C (bitvector 1))
(define (make-state)
  (state A C (vector R0 R1 R2 R3 R4 R5 R6 R7)))

; instructions
(struct MOV-A-Rn (n) #:transparent)
(struct MOV-Rn-A (n) #:transparent)
(struct ANL-A-Rn (n) #:transparent)
(struct ORL-A-Rn (n) #:transparent)
(struct XRL-A-Rn (n) #:transparent)
(struct XCH-A-Rn (n) #:transparent)
(struct MOV-A-i (i) #:transparent)
(struct ANL-A-i (i) #:transparent)
(struct ORL-A-i (i) #:transparent)
(struct SWAP-A () #:transparent)
(struct CLR-C () #:transparent)
(struct MOV-C-An (n) #:transparent)
(struct MOV-An-C (n) #:transparent)
(struct RLC-A () #:transparent)
(struct RRC-A () #:transparent)
(struct RL-A () #:transparent)
(struct RR-A () #:transparent)

(define (print-insn insn)
  (match insn
    [(MOV-A-Rn n) (printf "MOV A, R~s~n" n)]
    [(MOV-Rn-A n) (printf "MOV R~s, A~n" n)]
    [(ANL-A-Rn n) (printf "ANL A, R~s~n" n)]
    [(ORL-A-Rn n) (printf "ORL A, R~s~n" n)]
    [(XRL-A-Rn n) (printf "XRL A, R~s~n" n)]
    [(XCH-A-Rn n) (printf "XCH A, R~s~n" n)]
    [(MOV-A-i i)  (printf "MOV A, #0x~x~n" (bitvector->natural i))]
    [(ANL-A-i i)  (printf "ANL A, #0x~x~n" (bitvector->natural i))]
    [(ORL-A-i i)  (printf "ORL A, #0x~x~n" (bitvector->natural i))]
    [(SWAP-A)     (printf "SWAP A~n")]
    [(CLR-C)      (printf "CLR C~n")]
    [(MOV-C-An n) (printf "MOV C, ACC.~s~n" n)]
    [(MOV-An-C n) (printf "MOV ACC.~s, C~n" n)]
    [(RLC-A)      (printf "RLC A~n")]
    [(RRC-A)      (printf "RRC A~n")]
    [(RL-A)       (printf "RL A~n")]
    [(RR-A)       (printf "RR A~n")]))

(define (print-prog prog)
  (for-each print-insn prog))

; sketches
(define (??insn)
  (define n (choose* 0 1)); 2 3 4 5 6 7))
  (define-symbolic* i (bitvector 8))
  (choose* (MOV-A-Rn n)
           (MOV-Rn-A n)
           (ANL-A-Rn n)
           (ORL-A-Rn n)
           (XRL-A-Rn n)
           (XCH-A-Rn n)
           (MOV-A-i i)
           (ANL-A-i i)
           (ORL-A-i i)
           (SWAP-A)
           (CLR-C)
           (MOV-C-An n)
           (MOV-An-C n)
           (RLC-A)
           (RRC-A)
           (RL-A)
           (RR-A)))

(define (??prog depth)
 (if (= depth 0) null
  (choose* null
   (cons (??insn) (??prog (- depth 1))))))

; symbolic interpreter
(define (run-insn S insn)
  (match insn
    [(MOV-A-Rn n)
     (set-state-A! S (state-Rn-ref S n))]
    [(MOV-Rn-A n)
     (state-Rn-set! S n (state-A S))]
    [(ANL-A-Rn n)
     (set-state-A! S (bvand (state-A S) (state-Rn-ref S n)))]
    [(ORL-A-Rn n)
     (set-state-A! S (bvor  (state-A S) (state-Rn-ref S n)))]
    [(XRL-A-Rn n)
     (set-state-A! S (bvxor (state-A S) (state-Rn-ref S n)))]
    [(XCH-A-Rn n)
     (let ([A (state-A S)] [Rn (state-Rn-ref S n)])
       (set-state-A! S Rn) (state-Rn-set! S n A))]
    [(MOV-A-i i)
     (set-state-A! S i)]
    [(ANL-A-i i)
     (set-state-A! S (bvand (state-A S) i))]
    [(ORL-A-i i)
     (set-state-A! S (bvor  (state-A S) i))]
    [(SWAP-A)
     (let ([A (state-A S)])
       (set-state-A! S (concat (extract 3 0 A) (extract 7 4 A))))]
    [(CLR-C)
     (set-state-C! S (bv 0 1))]
    [(MOV-C-An n)
     (set-state-C! S (extract n n (state-A S)))]
    [(MOV-An-C n)
     (set-state-A! S (replace-bit 8 n (state-A S) (state-C S)))]
    [(RLC-A)
     (let ([A (state-A S)] [C (state-C S)])
       (set-state-A! S (concat (extract 6 0 A) C))
       (set-state-C! S (extract 7 7 A)))]
    [(RRC-A)
     (let ([A (state-A S)] [C (state-C S)])
       (set-state-A! S (concat C (extract 7 1 A)))
       (set-state-C! S (extract 0 0 A)))]
    [(RL-A)
     (let ([A (state-A S)])
       (set-state-A! S (concat (extract 6 0 A) (extract 7 7 A))))]
    [(RR-A)
     (let ([A (state-A S)])
       (set-state-A! S (concat (extract 0 0 A) (extract 7 1 A))))]
    ))

(define (run-prog S prog)
 (for-each (lambda (insn) (run-insn S insn)) prog))

; examples
(define (optimize-8b-rotate-right n)
 (define S  (make-state))
 (define S* (make-state))
 (define prog (??prog 4))
 (run-prog S* prog)
 (define model
  (optimize
   #:minimize
   (list (length prog))
   #:guarantee
   (assert
    (forall (symbolics S)
     (and
      (bveq (rotate-right 8 n (state-R0 S)) (state-R0 S*))
      (bveq (state-R1 S) (state-R1 S*))
      (bveq (state-R2 S) (state-R2 S*))
      (bveq (state-R3 S) (state-R3 S*))
      (bveq (state-R4 S) (state-R4 S*))
      (bveq (state-R5 S) (state-R5 S*))
      (bveq (state-R6 S) (state-R6 S*))
      (bveq (state-R7 S) (state-R7 S*)))))))
 (if (unsat? model) #f
     (evaluate prog model)))

(optimize-8b-rotate-right 1)
