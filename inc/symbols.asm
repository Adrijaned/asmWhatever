;; Returns the xy coordinates of cursor
;; IN:
;; OUT:
;; - rdx The X coordinate of the cursor
;; - rax The Y coordinate of the cursor
;; DIRTY:
;; - rdi
;; - rsi
;; - r10
;; ERR:
extern	getCursorPos

;; Parses string as unsigned doubleword int
;; IN:
;; - rax Location of the first digit of the int
;; - rdi Length of the string with the number
;; OUT:
;; - eax The parsed int
;; DIRTY:
;; - rdi 0
;; ERR:
;; - EINVAL If rdi is 0 or less
;; - E_ENOTSUP If non-digit is encountered while parsing 
extern	strToDW

;; Converts unsigned doubleword int to string
;; IN:
;; - eax The int to convert
;; - rdx Pointer to memory to store the result to.
;; Caller is responsible for ensuring the validity
;; and sufficient length of this memory.
;; OUT:
;; - rax Length of the resulting string
;; DIRTY:
;; ERR:
extern	DWToStr

;; Returns the index of char in string
;; IN:
;; - al The char to find
;; - rdx Pointer to the searched-through string
;; - rsi Length of the searched-through string
;; OUT:
;; - rax Index of the first occurence of target char in string.
;; Contains -1 if char was not found.
;; DIRTY:
;; ERR:
extern	findChar

;; Sets up console into non-canonical mode.
;; Must be called as first thing in the program.
;; IN:
;; OUT:
;; DIRTY:
;; - rax
;; - rdi
;; - rsi
;; - rdx
;; ERR:
;; - E_LOGERROR When called while terminal is already set up.
extern	setIoctl

;; Resets console to original settings.
;; Must be called as last thing in the program.
;; IN:
;; OUT:
;; DIRTY:
;; - rdi
;; - rsi
;; - rax
;; - rdx
;; ERR:
;; - E_LOGERROR When called without prior call to setIoctl.
extern resetIoctl

;; Returns the current size of the terminal
;; IN:
;; OUT:
;; - rdx The width of the terminal
;; - rax The height of the terminal
;; DIRTY:
;; - rdi
;; - rsi
;; - r10
;; ERR:
extern getScreenDimensions
