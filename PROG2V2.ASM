;=====================================================================================
;=================================STACK SEGMENT=======================================
;=====================================================================================

MyStack SEGMENT STACK                   

    DW 256 DUP (?)                  ;This is the stack (not sure if a larger stack is needed)

MYStack ENDS                        ;End Segment

;=====================================================================================
;=================================DATA SEGMENT========================================
;=====================================================================================

MyData SEGMENT
    
    dataSegmentReference DW 0C32Ah              ;initializes the data segement
    
    upperLeftCornerPosition DW 360h             ;upper left corner of the box 
    
    borderType DB 0h                            ;either double or single border single being 0 and double being 1
    
    backgroundColor DB 0001b                    ;the color of the background of the ascii of the box
    
    foregroundColor DB 0010b                    ;the color of the text of the ascii of the box
    
    boxHeight DB 10h                            ;the height of the interior of the box
    
    graphics DB 0DAh,0C4h,0BFh,0B3h,0C0h,0D9h   ;the peices for the single and double line box
             DB 0C9h,0CDh,0BBh,0BAh,0C8h,0BCh
             
    UpperLeftCorner EQU 0                       ;CONSTANTS
    HorizontalLine  EQU 1                       ;
    UpperRightCorner EQU 2                      ;
    verticalLine EQU 3                          ;
    BottomLeftCorner EQU 4                      ;
    BottomRightCorner EQU 5                     ;
    
    snowScreen DW 2000 DUP(?)                   ;
    
    snowFlakesPerLine DW 63                     ;
    
    snowFallSpeed DW 9                         ;
    
    randomNumber DW 00001001b                   ;
    randomNumberToUseForCalculations DW 00000000b; 
    
    startTime DW 20                             ;
MyData ENDS                                     ;End Segment

;=====================================================================================
;=================================CODE SEGMENT========================================
;=====================================================================================

MyCode SEGMENT
    ASSUME CS:MyCode, DS:MyData     ;Tells the assembler what segments the code
                                    ;registers refer to in the following code   
                            
;=====================================================================================
;=================================MAIN PROC===========================================
;=====================================================================================

MyMain PROC                        ;begins execution here which starts with drawing the box
    
    MOV AX,MyData                   ;sets up the the data segment register for later use
    
    MOV DS,AX                       ;
    
    MOV AX, 0B800h                  ;sets up access to the screen memory
    
    MOV ES, AX                      ;
    
    MOV DI,upperLeftCornerPosition  ;initializes the starting position of DI
    
    CALL DrawBox                    ;draws the box of specified things
    
    CALL GenerateFirstRandomNumber  ;gets the seed number and "randomizes" it
    
    CALL KeyStrokeChecker           ;checks for keyboard commands and modifys box according to those commands  
    
MyMain ENDP
;=====================================================================================
;=================================DRAWBOX PROC========================================
;=====================================================================================
DrawBox PROC

;ON ENTRY
    ;
;ON EXIT
    ;~   
    PUSH DI CX AX BX DX               ;
;-----------------------------------
    
    MOV AH, 00h                     ;initializes the box's width 
    
    MOV AL,boxHeight                ;initializes the box's width
    
    ADD AL,AL                       ;doubles the boxes width to make the box an actual box
    
    SUB AL,2                        ;subtracts 2 from the width to create the width counter
    
    MOV CH,00h                      ;sets the high byte of CX to zero 
    
    MOV CL,boxHeight                ;sets CL to the height of the box
    
    MOV BL,foregroundColor          ;
    
    MOV DL,backgroundColor          ;
    
    SHL BL,4                        ;
    OR DL,BL                        ;Appends the colors specified to each other
    
    
    MOV BH,DL                ;sets the color of the upper left corner
    
        
    CALL DrawTopLine
    
    ADD DI,160                      ;advances to the next line
    
    SUB CL,2                        ;subtracts 2 from the height to create the height counter

numLinesLoop:

    CMP CL,0                        ;if the height counter is zero
    
    JE DrawLastLine                 ;exits the loop
    
    CALL DrawMiddleLine             ;draws the middle line when called
    
    ADD DI,160                      ;advances to the next line
    
    DEC CL                          ;decremenets the height counter
    
    JMP numLinesLoop                ;continues the loop if the height counter is not zero
    
DrawLastLine:
    CALL DrawBottomLine             ;draws the bottom line of the box
;-----------------------------------
    POP DX BX AX CX DI                    ;
    RET
DrawBox ENDP
;=====================================================================================
;=================================DRAW TOP LINE PROC==================================
;=====================================================================================
DrawTopLine PROC
    
    PUSH BX AX DI
;-----------------------------------        

    LEA SI,graphics                 ;SI points to the array of the box parts
    
    CMP borderType,1                ;is the border doubled?
    
    JE skip                         ;if so then add 6 to SI
        
    ADD SI,6                        ;adding 6 to SI to make the pointer point to the double lined parts
;-----------------------------------   
 skip:
 
    MOV BL,[SI + UpperLeftCorner]   ;initializes the upperleft corner piece 
    
    MOV ES:[DI],BX                  ;puts the previously defined peice onto the screen    
 ;----------------------------------
dashLoop:
    MOV BL,[SI+HorizontalLine]      ;initializes the horizontal line piece
    
    CMP AL,0                        ;if the width counter is zero
    JE  endDashLoop                 ;exit the loop
    
    DEC AL                          ;decrements until the width counter is zero
    INC DI                          ;increments DI twice to get to the next character position
    INC DI                          ;
    
    MOV ES:[DI],BX                  ;puts the character placed into BX earlier to the screen
    
    JMP dashLoop                    
    
endDashLoop:
    
    MOV BL,[SI+UpperRightCorner]    ;initializes the upper right corner piece once done with the loop
    
    MOV ES:[DI],BX                  ;puts the corner peice on the screen
       
    POP DI AX BX
    
    RET
DrawTopLine ENDP
;=====================================================================================
;=================================DRAW BOTTOM LINE PROC===============================
;=====================================================================================

DrawBottomLine PROC
    PUSH AX DI BX
    
    MOV BL,[SI + BottomLeftCorner]  ;initializes the bottom left corner peice
    
    MOV ES:[DI],BX                  ;puts the bottom left corner on the screen
 ;----------------------------------
dashLoop2:
    MOV BL,[SI+HorizontalLine]      ;initializes the horizontal line piece
    
    CMP AL,0                        ;if the width counter is zero
    JE  skip1                       ;skips to the first skip
    
    DEC AL                          ;decrements the width counter until zero
    
    INC DI                          ;increments DI twice to get to the next character
    INC DI                          ;increments DI twice to get to the next character
    
    MOV ES:[DI],BX                  ;places a horizontal line onto the current screen position
    
    JMP dashLoop2                    
skip1:    
    MOV BL,[SI+BottomRightCorner]   ;inititalizes the bottom right corner peice to be used
    
    MOV ES:[DI],BX                  ;puts the corner peice on the screen

    POP BX DI AX
    RET
DrawBottomLine ENDP
;=====================================================================================
;=================================DRAW MIDDLE LINE PROC===============================
;=====================================================================================

DrawMiddleLine PROC
    PUSH AX DI
    
    MOV BL,[SI+VerticalLine]        ;initialize the vertical line character 
    
    MOV ES:[DI],BX                  ;puts the vertical line onto the screen
;-----------------------------------    
horizontalLoop:
    
    CMP AL,0                        ;if the width counter is zero
    JE skip2                        ;jump out of the loop into the skip label

    DEC AL                          ;decrements the width counter until zero
    INC DI                          ;moves the position on the screen by 2
    INC DI                          ;moves the position on the screen by 2   
    
    CALL DrawSnow                   ;places either a space or a snowflake in the appropriate place
    
    JMP horizontalLoop              ;loops back to the top until the width counter is zero
;-----------------------------------   
skip2:
    MOV ES:[DI],BX                  ;moves the vertical line onto the screen
    
    POP DI AX
    RET
DrawMiddleLine ENDP
;=====================================================================================
;================================= KEYSTROKE CHECKER =================================
;=====================================================================================

KeyStrokeChecker PROC
    PUSH AX
    
    MOV AH,00h                      ;
    INT 1Ah                         ;gets the starting times timer ticks
    
    MOV startTime,DX                ;
    topOfKeyCheckLoop:
    
    MOV AH,11h                      ;
    INT 16h                         ;Checks buffer status of the keyboard
    JNZ processKeys           ;if no keys are in the buffer doBackground stuff
    
;======================================================================
;======================================================================
 ;-----------------------------------   
doBackgroundStuff:
    INC WORD PTR ES:[160]           ;   
    CALL CheckTimer                 ;
    JMP topOfKeyCheckLoop           ;starts the loop over
;======================================================================
processKeys:
    MOV AH,10h                      ;
    INT 16h                         ;peek at the buffer to read the key
;-----------------------------------    
    CMP AX,48E0h                    ;up arrow???
    JNE rightArrow                  ;if not check next key
    CALL ProcessUpArrow             ;if it is then process it
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------    
rightArrow:
    CMP AX,4DE0h                    ;right arrow???????
    JNE downArrow                   ;if not, check next key
    CALL ProcessRightArrow           ;if it is then process it
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------   
downArrow:
    CMP AX,50E0h                    ;down arrow????
    JNE leftArrow                   ;if not check next key
    CALL ProcessDownArrow           ;if it is then process if
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------
leftArrow:
    CMP AX,4BE0h                    ;left arrow?????
    JNE f1Key                       ;if not check next key
    CALL ProcessLeftArrow           ;if it is then process it
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------    
f1Key:
    CMP AX,3B00h                    ;F1 key??????
    JNE f2Key                       ;if not check next key
    CALL ProcessF1Key               ;if it is then process it
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------   
f2Key:
    CMP AX,3C00h                    ;F2 key??????
    JNE f3Key                       ;if not check next key
    CALL ProcessF2Key               ;if it is then process if
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------    
f3Key:
    CMP AX,3D00h                    ;F3 key??????
    JNE escKey                      ;if not check next key
    CALL ProcessF3Key               ;if it is then process it
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------    
escKey:
    CMP AL,1Bh                      ;esc key???????
    JNE f6Key                       ;if not keep looping
    CALL ProcessEscKey              ;if it is then process it
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------    
f6Key:
    CMP AX,4000h                    ;f6 Key????
    JNE f7Key                       ;if not keep looping
    CALL ProcessF6Key               ;if it is then process it
    JMP endOfProcessKeys            ;then continue to loop
;-----------------------------------
f7Key:
    CMP AX,4100h                    ;f7 Key????
    JNE f8Key                       ;if not then keep looping
    CALL ProcessF7Key               ;if it is then process it
    JMP endOfProcessKeys            ;then continue to loop
 ;----------------------------------
 f8Key:
    CMP AX,4200h                    ;f8 Key????
    JNE f9Key                       ;if not then keep looping
    CALL ProcessF8Key               ;if it is then process it
    JMP endOfProcessKeys            ;then keep looping
;-----------------------------------
f9Key:
    CMP AX,4300h                    ;f9 Key?????
    JNE controlUpArrow              ;if not then end
    CALL ProcessF9Key               ;if it is then process it
    JMP endOfProcessKeys
;-----------------------------------
controlUpArrow:
    CMP AX,8DE0h                    ;control up arrow??
    JNE controlDownArrow            ;if not then keep looping
    CALL ProcessCtrlUpArrow         ;if it is then process it
    JMP endOfProcessKeys            ;keep looping
;-----------------------------------
controlDownArrow:
    CMP AX,91E0h                    ;control down arrow
    JNE endOfProcessKeys            ;if not then keep looping
    CALL ProcessCtrlDownArrow       ;
    ;end loop
endOfProcessKeys:
    JMP topOfKeyCheckLoop           ;starts loop over
;======================================================================    
    POP AX
    RET
 KeyStrokeChecker ENDP   
;=====================================================================================
;================================= PROCESS UP ARROW ==================================
;=====================================================================================
ProcessUpArrow PROC
    
    CMP DI,160                      ;does the box have room to move up???
    JL dontMoveUp                   ;if not dont move
    CALL Cls
    SUB DI,160                      ;if it does then move the box up a line
    CALL DrawBox                    ;redraw
    
dontMoveUp:
    RET
ProcessUpArrow ENDP
;=====================================================================================
;================================= PROCESS DOWN ARROW ================================
;=====================================================================================
ProcessDownArrow PROC
    PUSH BX AX
        
    MOV AL,boxHeight                ;
    MOV BL,160                      ;multiplies the box height by 160 to get the off set of DI
    MUL BL                          ;
    
    ADD AX,DI                       ;gets the bottom left corner of the box
    
    CMP AX,3998                     ;can DI move down??
    JG dontMoveDown                 ;if not dont move it
    CALL Cls
    ADD DI,160                      ;moves di down a line
    CALL DrawBox                    ;redraws the box
    
dontMoveDown:
    POP AX BX
    RET
    
ProcessDownArrow ENDP
;=====================================================================================
;================================= PROCESS LEFT ARROW ================================
;=====================================================================================
ProcessLeftArrow PROC
    PUSH BX AX
    MOV AX,DI                       ;sets up the top right corners position of the box to be divided
    
    MOV BL,160                      ;sets up the divisor
    
    DIV BL                          ;does the division
    CMP AH,0                        ;is there a remainder
    JZ dontMoveLeft                 ;if not dont move left
    CALL Cls
    SUB DI,2                        ;moves the top right corner to the left one space
    CALL DrawBox                    ;redraws the box
    
dontMoveLeft:
    POP AX BX
    RET

ProcessLeftArrow ENDP
;=====================================================================================
;================================= PROCESS RIGHT ARROW ===============================
;=====================================================================================
ProcessRightArrow PROC
    PUSH BX AX DX
    MOV AH,00
    MOV AL,boxHeight       ;puts the box height into AX to be used for arithmatic
    MOV BL,4                        ;
    
    
    MUL BL                          ;multiplies the height by 2 to get the width
    SUB AX,4                        ;subtracts one from ax allow for the next line to make sense
    MOV DX,0
    ADD AX,DI                       ;adds di to the width to get the top right corners position

    MOV BX,160                      ;sets up the divisor
    
    DIV BX                          ;divides the position of the top right corner by 158
    
    CMP DX,158                      ;is there a remainder?
    JE dontMoveRight                ;if not dont move right
    
    
    CALL Cls
    
                                    ;if there is then move
    ADD DI,2                        ;add 2 to DI
    
    CALL Cls
    CALL DrawBox                    ;redraws the box

dontMoveRight:
    MOV AX,DI
    POP DX AX BX
    RET
    
ProcessRightArrow ENDP
;=====================================================================================
;================================= PROCESS CTRL UP ARROW =============================
;=====================================================================================
ProcessCtrlUpArrow PROC
    PUSH BX AX DX
    
    CMP boxHeight,23                ;is the box allowed to expand anymore??
    JG dontIncreaseSize             ;if not end the proc
    
    MOV AH,00                       ;
    MOV AL,boxHeight                ;
    MOV BL,4                        ;
    
    MUL BL
    
    SUB AX,4                        ;
    ADD AX,DI                       ;
    
    MOV BX,160                      ;
    MOV DX,0
    DIV BX                          ;
    
    CMP DX,158                      ;
    JE dontIncreaseSize             
    
    CMP DX,156                      ;
    JE dontIncreaseSize
    
    CALL ProcessUpArrow
                                    ;if so then expand                              
    ADD boxHeight,1                 ;increment the box's height if its not the max size
    ;dont actually have to clear the screen here

dontIncreaseSize:
    POP DX AX BX 
    RET
ProcessCtrlUpArrow ENDP
;=====================================================================================
;================================= PROCESS CTRL DOWN ARROW ===========================
;=====================================================================================
ProcessCtrlDownArrow PROC
    
    CMP boxHeight,6                 ;is the box allowed to shrink?
    JLE dontDecreaseSize            ;if not end the proc
    
                                    ;if so then shrink
    SUB boxHeight,1                 ;decrements the box's height if its not at the smallest size
    ; do the check here

    
    
    CALL DrawBox
    
dontDecreaseSize:
    RET
ProcessCtrlDownArrow ENDP
;=====================================================================================
;================================= PROCESS F1 KEY ====================================
;=====================================================================================
ProcessF1Key PROC

    INC borderType                  ;incremtents the border type and only letting it be either zero or one
    AND borderType,00000001b        ;
    ;the parts are being overwritten so no need to clear the screen
    CALL DrawBox                    ;redraws the box
   
    RET
ProcessF1Key ENDP
;=====================================================================================
;================================= PROCESS F2 KEY ====================================
;=====================================================================================
ProcessF2Key PROC
    
    INC foregroundColor             ;increments the foreground color and not letting it grow past the nibble
    AND foregroundColor,00001111b   ;look in notes
    ;the parts are being overwritten so no need to clear the screen
    CALL DrawBox                    ;redraw the box

    RET
ProcessF2Key ENDP
;=====================================================================================
;================================= PROCESS F3 KEY ====================================
;=====================================================================================
ProcessF3Key PROC
    
    INC backgroundColor             ; increments the background color and not letting it grow past the nibble
    AND backgroundColor,00001111b   ;look in notes for clarification
    CALL DrawBox                    ;redraw the box
    RET
ProcessF3Key ENDP

;=====================================================================================
;================================= PROCESS ESC KEY ===================================
;=====================================================================================
ProcessEscKey PROC
    ;clearing the screen here doesn't seem necesarry
    MOV AH,4Ch                      ;returns control back to the OS
    INT 21h   

ProcessEscKey ENDP
;=====================================================================================
;================================ CLS ================================================
;=====================================================================================
Cls PROC
    PUSH CX DI
    
    MOV CX,2000                     ;number of repititions
    
    MOV DI,0                        ;
ClearLoop:
    MOV ES:[DI],0720h               ;
    ADD DI,2                        ;
LOOP clearLoop
    
    POP DI CX   
    RET
    
Cls ENDP
;=====================================================================================
;============================ SCROLL SNOW SCREEN DOWN ================================
;=====================================================================================

ScrollSnowScreenDown PROC
    PUSH SI DI ES
    INC WORD PTR ES:[3998-160]           ;
    MOV CX,2000-80                  ;how many repititions the MOVSW will be doing
    
    PUSH DS                         ;
    POP ES                          ;puts DS into ES
    
    LEA SI,snowScreen +3998-160     ;
    LEA DI,snowScreen + 3998        ;
    
    STD                             ;flis the direction flag to reverse
    REP MOVSW                       ;puts DS:[SI] into ES:[DI]
    
    POP ES DI SI                    
    RET
 ScrollSnowScreenDown ENDP
 
;=====================================================================================
;================================ PROCESS F6 KEY =====================================
;=====================================================================================

ProcessF6Key PROC
    
    DEC snowFlakesPerLine           ;
    
    AND snowFlakesPerLine, 00111111b; doesnt allow for the nubmer to be larger than 63
    
    RET
ProcessF6Key ENDP

;=====================================================================================
;================================ PROCESS F7 KEY =====================================
;=====================================================================================

ProcessF7Key PROC

    INC snowFlakesPerLine           ;
    
    AND snowFlakesPerLine, 00111111b; doesnt allow for the nubmer to be larger than 63    
    
    RET
ProcessF7Key ENDP

;=====================================================================================
;================================ PROCESS F8 KEY =====================================
;=====================================================================================

ProcessF8Key PROC
    PUSH AX

    MOV AX,snowFallSpeed
    CMP AX,42
    JL  increaseTicks
    JMP skipStuff
increaseTicks:
    INC snowFallSpeed
    CALL DisplayInt
    CALL Pause
skipStuff:
    POP AX 
RET
ProcessF8Key ENDP

;=====================================================================================
;================================ PROCESS F9 KEY =====================================
;=====================================================================================

ProcessF9Key PROC
    PUSH AX
    ;DEC snowFallSpeed
    
    MOV AX,snowFallSpeed
    CMP AX,1                   ;3 seconds inbetween
    JG decreaseTicks
    JMP endStuff
decreaseTicks:
    DEC snowFallSpeed
    CALL DisplayInt
    CALL Pause
endStuff:
    POP AX 
RET
ProcessF9Key ENDP
;=====================================================================================
;================================ ADD NEW SNOW =======================================
;=====================================================================================
AddNewSnow PROC

PUSH CX SI
    
    CALL scrollSnowScreenDown       ;scrolls the snowscreen down
    LEA SI, snowScreen              ; initializes the snow screen
    MOV CX,160                      ;
    
topSnowRowClearLoop:
    CMP CX,0                        ;is cx zero?
    JLE doneClearingTopSnowRow      ;if so get out of the loop
    
    DEC CX                          ;
    
    DEC CX                          ;if not subtract 2 from CX
    
    PUSH SI                         ;saves the pointer to the first position of the snowscreen
    
    ADD SI,CX                       ;
    
    MOV DS:[SI],0720h               ;puts a white space into the snow screen
    
    POP SI                          ;restores SI back to the first position of the snow screen
    
    JMP topSnowRowClearLoop         ;continues the loop

doneClearingTopSnowRow:
    MOV CX,snowFlakesPerLine        ;number of times this loop will itterate

addNewSnowLoop:    
    CALL GenerateRandomNumber       ;
    LEA SI,snowScreen               ;
    
    MOV AX,randomNumber             ;move the random number into AX
    
    SHL AX,1                        ;doubles the random number
                                    ;its only an even number
    PUSH SI                         ;
    ADD SI,AX                       ;moves SI forward a random even number from 0-158
    
    MOV DS:[SI],072Ah               ;places a white on black snowflake on random position on the snow screen
    
    POP SI
    
LOOP addNewSnowLoop                 ;
    
    POP SI CX

    RET
AddNewSnow ENDP
;=====================================================================================
;================================ DRAW SNOW ==========================================
;=====================================================================================
DrawSnow PROC

    PUSH SI AX
    INC BYTE PTR ES:[3998]          ;
    LEA SI, snowScreen              ; initializes the snow screen
    
    ADD SI,DI                       ;sets SI to the off set of DI
    
    MOV AX,DS:[SI]                  ;places whats in the fake snow screen at DIS current position into AX
    
    CMP AX,072Ah                    ;if theres a star on the screen
    JZ placeAStar                   ;if so place a star
    
    MOV ES:[DI],0720h               ;if not places a space on the screen
    JMP endOfDraw                   ;jumps to the end
    
placeAStar:
    MOV ES:[DI],072Ah               ;places a star on the real screen

endOfDraw:

    POP AX SI
    
    RET
DrawSnow ENDP

;=====================================================================================
;================================ GENERATE RANDOM NUMBER =============================
;=====================================================================================
GenerateRandomNumber PROC
    PUSH AX BX DX
    
    MOV AX,randomNumberToUseForCalculations
    
    MOV BX,37                   ;prime number to multiply the random by
    MUL BX                      ;
    
    ADD AX,67                   ;another prime number to add to the product
    
    MOV randomNumberToUseForCalculations, AX
    MOV BX,80                   ;
    DIV BX                      ;DX:AX % 80
    
    MOV randomNumber,DX         ;places the newly generated "random" number back into the variable
                        ;remember to store ax as the random number
    POP DX BX AX
    RET
GenerateRandomNumber ENDP

;=====================================================================================
;================================ GENERATE FIRST RANDOM NUMBER =======================
;=====================================================================================
GenerateFirstRandomNumber PROC
    PUSH AX BX DX CX
    
    MOV AH,00h                  ;
    INT 1Ah                     ;
    
    MOV randomNumberToUseForCalculations,DX         ;sets the seed to a random number based on the timer ticks
    
    MOV AX,randomNumberToUseForCalculations         ;
    
    MOV BX,37                   ;prime number to multiply the random number by
    MUL BX                      ;
    
    ADD AX,67                   ;adds another prime number to the product of the random and the previous prime number
    
    MOV BX,80                   ;
    DIV BX                      ;DX:AX % 80
    MOV randomNumberToUseForCalculations,DX         ;
    
    POP CX DX BX AX
    RET
GenerateFirstRandomNumber ENDP

;=====================================================================================
;================================ CHECK TIMER ========================================
;=====================================================================================
CheckTimer PROC
    
    PUSH DX CX AX
    
    MOV AH,00h                  ;
    INT 1Ah                     ;gets the timer ticks
    
    SUB DX,startTime            ;gets the difference of the starting time from the current time
    
    CMP DX,snowFallSpeed        ;
    JL dontDoProcessing         ;is the diffenece of startTime less than the snow fall speed?
    
    CALL AddNewSnow             ;scrolls the snow screen down and adds a new row of snow
    CALL Cls
    CALL DrawBox                ;redraws the box

    MOV CX,snowFallSpeed        ;
    ADD startTime,CX            ;not sure if this is proper?!?!?????????????????????????????    
dontDoProcessing:

        
    POP AX CX DX
    
    RET
CheckTimer ENDP
;======================================================================================
;======================== PAUSE ======================================================
;======================================================================================
Pause PROC
    PUSH AX
    
    MOV AH,10h  
    
    INT 16h
    
    
    POP AX
    RET
ENDP
;==============================================================================================
;================================ DISPLAY INT =================================================
;==============================================================================================
DisplayInt PROC
    PUSH DI AX BX DX
    ;AX IS THE THING WE WILL BE DISPLAYING
    ;DI WILL BE THE POSITION WE WANT TO DISPLAY THE NUMBER AT
    
    MOV DI,80
    MOV BX,10
    
conversionLoop:
    MOV DX,0                        ;clears DX
    
    DIV BX                          ;
    
    ADD DL,'0'                      ;
    MOV DH,07h                      ;
    MOV ES:[DI],DX                  ;
    SUB DI,2                        ;
    
    CMP AX,0                        ;
    JA conversionLoop
    POP DX BX AX DI
    
    RET
ENDP
MyCode ENDS
END MyMain