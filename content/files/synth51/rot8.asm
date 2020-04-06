; rotate right R0 by 0
; rotate right R0 by 1
MOV A, R0
RR A
MOV R0, A
; rotate right R0 by 2
MOV A, R0
RR A
RR A
MOV R0, A
; rotate right R0 by 3
XCH A, R0
RL A
SWAP A
MOV R0, A
; rotate right R0 by 4
MOV A, R0
SWAP A
MOV R0, A
; rotate right R0 by 5
MOV A, R0
SWAP A
RR A
XCH A, R0
; rotate right R0 by 6
MOV A, R0
RL A
RL A
MOV R0, A
; rotate right R0 by 7
MOV A, R0
RL A
MOV R0, A
