#lang racket

;NAME: Vidulash R.
;SNUM: 8190398

;Greeting messages and input for file name that will be used in functions
(display "Welcome to Hungarian Match Program with Scheme!")(newline)
(display "Ensure file is in this directory.")(newline)
(display "Please enter Cost Matrix filename: ")
(define filename (read-line))



;Helper Function that writes output file
(define proc-out-file
   (lambda (filename proc)
     (let ((p (open-output-file filename #:exists 'replace)));replaces file if it already exists
       (let ((v (proc p)))
         (close-output-port p)
         v))))


;Helper function that reads csv file and puts it into a list
(define (readCostMatrixCSV file)
    (define (readFile file)
        (let ((p (open-input-file file)))
          (let f ((x (read p))) ;read line from file
            (if (eof-object? x) ; check for eof
                (begin 
                  (close-input-port p) ;if end of object close port
                  '())
                ;Else if not end
                (if (number? (string->number (to-string x))) ;if number add it to list
                    (cons (string->number (to-string x)) (f (read p)))
                    ;else if not string
                    (cons (string->number (to-string x)) (f (read p)))))
            )))
      (begin ;filters list for only numbers and splits them by the sqrt of the length of list
      (split-by (filter number?(readFile file)) (sqrt(length (filter number?(readFile file)))))))


;Additional function to implement lookup table with numbers to symbols
(define (mapping num sym)
  ;Defines local variable table with construction of pairs with given num and sym
  (let ((table (map cons num sym)))
    (lambda (num) (cond ((assq num table) => cdr) ;Associating lists returns symbol given number and the table to lookup (Ex. (1 a) will return cdr a)
                        (else #f))))) ;Else if not found, simply returns false
;Creates lookup table with the alphabet symbols mapped with numerical values as follows for ROWS
(define lookup-row (mapping '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25)
                              '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")))

;Creates a backup lookup table with the roman symbols mapped with numerical values as follows for COLUMNS incase size changes within one run
(define lookup-col2 (mapping '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25)
                              '("I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" "XI" "XII" "XIII" "XIV" "IV" "XVI" "XVII" "XVIII" "XIX" "XX" "XXI" "XXII" "XIII" "XXIV" "XXV" "XXVI")))


;Additional function that converts obj to string 
(define (to-string obj)
  (define q (open-output-bytes))
  (write obj q)
  (if (= (string-length (get-output-string q)) 1)
      (get-output-string q)
      ;Else
      (substring (get-output-string q) 9 (- (string-length (get-output-string q)) 1))) 
)

;Additional function that splits list into N lists in a single list
(define (split-by L n)
   (if (not (empty? L))
       (cons (take L n) (split-by (drop L n) n))
       '() ))

;Additional function that displays the given matrix in a visually simple way
(define (displaymatrix L)
       (if (null? L)
           (display "")
           (begin (display (car L))
                  (newline)
           (displaymatrix (cdr L))))
  (display "-----------"))


;Function for row reduction using minimum value from each row
(define (rowReduction L)
  ;Function that gets minimum value in a given row
  (define (minimum L)
    (cond ((null? (cdr L)) (car L))
          ((< (car L) (minimum (cdr L))) (car L))
          (else (minimum (cdr L)))) )
  ;Function that makes a list
  (define (listmaker L N R)
       (if (= N 0)
           R
           (listmaker L (- N 1) (append R (list L)))))
  ;Main function
     (if (null? L) ;If reach end of list return nothing
         null
        (begin
          (cons (map -(car L) (listmaker (minimum (car L)) (length (car L)) '()));Construct pair with rest of list
                (rowReduction (cdr L))))));loop



;Function for col reduction using minimum value from each column
(define (colReduction L I)
   ;Function to get specific column
   (define (getCol L N)
        (cond
          [(null? L) '()]
          [else (cons (list-ref (car L) N) (getCol (cdr L) N))]))
   ;Function to get minium value in list
   (define (minimum L)
    (cond ((null? (cdr L)) (car L))
          ((< (car L) (minimum (cdr L))) (car L))
          (else (minimum (cdr L)))) )
    ;Function to modify value in a list
    (define (list-set L N val)
      (if (null? L)
        L
        (cons
         (if (zero? N)
             val
             (car L))
         (list-set (cdr L) (- N 1) val))))
  
    ;Function that applies reduction to each row  
    (define (col-set min N L)
       (if (null? L)
           L
           (cons (list-set (car L) N (- (list-ref (car L) N) min))
                 (col-set min N (cdr L)))))
     ;Main procedure   
     (if (< I 0)
         L
        (colReduction (col-set (minimum (getCol L I)) I L) (- I 1))));loop



;Function that checks if list has a N in it
(define (contains L N)
        (if (null? L);End of list return false
            #f
            (if (= (car L) N);if found, return true
                #t
                (contains (cdr L) N))));Else keep looking

;Function that checks how many N it contains in a given list/row
(define (howmanyrow L N)
       (length (indexes-of L N))) ;Get length of all indexes of a given number

;Function that checks how many N it contains in a given list/column
(define (howmanycol L Col N)
   ;Function to get specific column
   (define (getCol L N)
        (cond
          [(null? L) '()]
          [else (cons (list-ref (car L) N) (getCol (cdr L) N))]))
   (length (indexes-of (getCol L Col) N)))

;Function that checks how many N in total in the matrix
(define (howmanytotal L N)
     (if (null? L);End of list return 0
         0
         (+ (howmanyrow (car L) N) (howmanytotal (cdr L) N))));Else keep adding amount of a given number at each row

;Function that marks all values in a row and selects N
(define (markrow L N I Select C)
  ;Helper function to mark row
  (define (markrow2 L N I C) 
      (if (null? L) ;if end of list return modified row
          C
          (if (= (car L) 2) ;if 2 cover it to 3
              (markrow2 (cdr L) N (+ I 1) (append C '(3)))
              (if (= (car L) 3);if already covered make it 4
                  (markrow2 (cdr L) N (+ I 1) (append C '(4)))
                  (if (= (car L) 0) ;if a 0
                      (if (= N I) ;if selected make it 1
                          (markrow2 (cdr L) N (+ I 1) (append C '(1)))
                          (markrow2 (cdr L) N (+ I 1) (append C '(-1))))
                      (markrow2 (cdr L) N (+ I 1) (append C (list (car L) ))))))))
      (if (null? L) ;if end of matrix return modified matrix
          C
          (if (= Select I) ;if selected
              (markrow (cdr L) N (+ I 1) Select (append C (list(markrow2 (car L) N 0 '()))))
              (markrow (cdr L) N (+ I 1) Select (append C (list(car L)))))))
              

;Function that marks all values in a col and selects N
(define (markcol L Col N I C)
        (if (null? L);if end of list return marked matrix
            C
            (if (= (list-ref (car L) Col) 2) ;if a 2 cover it and make it 3
                (markcol (cdr L) Col N (+ I 1)(append C (list(list-set (car L) Col 3))))
                (if (= (list-ref (car L) Col) 3);if a 3 cover it twice and make it 4
                    (markcol (cdr L) Col N (+ I 1)(append C (list(list-set (car L) Col 4))))
                    (if (= (list-ref (car L) Col) 0) ;if a 0
                        (if (= N I) ; if selected make it 1
                            (markcol (cdr L) Col N (+ I 1)(append C (list(list-set (car L) Col 1))))
                            (markcol (cdr L) Col N (+ I 1)(append C (list(list-set (car L) Col -1)))))
                        (markcol (cdr L) Col N (+ I 1) (append C (list(car L)))))))))

;Function that gets smallest uncovered value
(define (smallestUncovered L M Min)
  ;Function that checks for lowest values in a list with indexes found in a given list Indx                         
  (define (checkMin L Indx Curr Min)
        (if (null? L)
            Min ;Return current min
            (if (contains Indx Curr) ;If current index is in index list
                (if (= Min -1) ;If first one 
                    (checkMin (cdr L) Indx (+ Curr 1) (list-ref L 0)); make it min
                    (if (< (list-ref L 0) Min) ;Else, if current index value is lower then current min
                        (checkMin (cdr L) Indx (+ Curr 1) (list-ref L 0));Update Min
                        (checkMin (cdr L) Indx (+ Curr 1) Min))) ;Dont update Min
                (checkMin (cdr L) Indx (+ Curr 1) Min)))) ;Keep checking

        (if (null? M) ;if end return current min
            Min
            (let*((twos (indexes-of (car M) 2)) ;get all indexes for twos uncovered
                        (curr (checkMin (car L) twos 0 -1))) 
                     (if (= Min -1) ;if no current min value, make it min
                         (smallestUncovered (cdr L) (cdr M) curr); get smallest uncovered value from row
                         (if (= curr -1) ;if its a -1 dont update
                             (smallestUncovered (cdr L) (cdr M) Min)
                             (if (< curr Min) ;if its below current min, update it
                                 (smallestUncovered (cdr L) (cdr M) curr)
                                 (smallestUncovered (cdr L) (cdr M) Min)
                                 ))))))

;Function that shifts zeroes using lowest uncovered value
(define (shiftzeroes L M Min C)
  (define (shiftrow L M Min Pos C)
        (if (null? L) ;if end of row return row
            C
            (if (= (list-ref M 0) 2) ;if uncovered subtract min from value
                (shiftrow (cdr L) (cdr M) Min (+ Pos 1) (append C (list (- (list-ref L 0) Min))))
                (if (= (list-ref M 0) 4);if double covered, add min to value
                    (shiftrow (cdr L) (cdr M) Min (+ Pos 1) (append C (list(+ (list-ref L 0) Min))))
                    (shiftrow (cdr L) (cdr M) Min (+ Pos 1) (append C (list (car L))))))))
        (if (null? L);if end of matrix return matrix
            C
            (shiftzeroes (cdr L) (cdr M) Min (append C (list(shiftrow (car L) (car M) Min 0 '()))))));modify row



;Function to make temporary matrix to display covered,covered twice or not                 
(define (tempmatrix L)
  ;Function that makes basic matrix with all twos before we add initial zeroes
  (define (matrixmaker L N1 N2 R)
       (define (listmaker L N R)
           (if (= N 0)
                R
                (listmaker L (- N 1) (append R (list L)))))
       (if (= N1 0)
           R
           (matrixmaker L (- N1 1) N2 (append R (list(listmaker L N2 '()))))))
    ;Function that adds zeros to initial matrix of two's
    (define (addzeroes L M C)
      (define (addzerorow L Zeros Pos C)
       (if (null? L)
           C
           (if (contains Zeros Pos)
               (addzerorow (cdr L) Zeros (+ Pos 1) (append C '(0)))
               (addzerorow (cdr L) Zeros (+ Pos 1) (append C '(2))))))
       ;Returns list where values are zeros
       (define (zeroslist L)
           (indexes-of L 0))
        (if (null? L)
           C
          (addzeroes (cdr L) (cdr M) (append C (list(addzerorow (car L) (zeroslist (car L)) 0 '()))))))
       (addzeroes L (matrixmaker 2 (length (car L)) (length (car L)) '())'()))


           


;Function to do row scanning 
(define (rowScanning L M Pos)
    (if (null? L);If scanned all rows
      M ;Return modified matrix
      ;Else
      (if (= (howmanyrow (list-ref M Pos) 0) 1) ;If row has only 1 0
          (rowScanning (cdr L) (markcol M (index-of (list-ref M Pos) 0) Pos  0 '()) (+ Pos 1));Draw line in that column
          (rowScanning (cdr L) M (+ Pos 1)))));Else keep moving

;Function to do column scanning
(define (colScanning L M Pos)
     (define (getCol L N)
        (cond
          [(null? L) '()]
          [else (cons (list-ref (car L) N) (getCol (cdr L) N))]))
     (if (= Pos (length L)) ;If scanned all columns
         M ;Return modified matrix
         ;Else
         (if (= (howmanycol M Pos 0) 1) ;If one 0 in column
             (colScanning L (markrow M Pos 0 (index-of (getCol L Pos) 0) '()) (+ Pos 1)) ;mark that row and select 0
             (colScanning L M (+ Pos 1)))));else, keep going

;Function to find row with least zeroes
(define (leastzeros L Row Checked Value Min)
        (if (null? L) ;If end of row return the current row
            Value
            (if (= Min -1) ;If start 
                (if (contains Checked Row); If row is already checked
                    (leastzeros (cdr L) (+ Row 1) Checked Value Min) ;Go to next row
                    (leastzeros (cdr L) (+ Row 1) Checked Row (howmanyrow (car L) 0)));Make current row the one with the minimum
                (if (contains Checked Row);Else if already checked once again
                    (leastzeros (cdr L) (+ Row 1) Checked Value Min); Go to next row
                    (if (< (howmanyrow (car L) 0) Min);Else, if it has less zeroes
                        (leastzeros (cdr L) (+ Row 1) Checked Row (howmanyrow (car L) 0));Make it row with min zeroes
                        (leastzeros (cdr L) (+ Row 1) Checked Value Min))))));Else loop again
           

                
;Function that checks if there are correct number of lines covering matrix
;if there are same number of 1's as size of matrix
(define (assigned? L)
  (define (samerowassign L)
       (if (null? L)
           #t
           (if (> (howmanyrow (car L) 1) 1)
               #f ;if more than 1 assignment in a row, return false
               (samerowassign (cdr L)))));else keep checking

   (define (samecolassign L Pos)
        (if (= Pos (length L))
            #t
            (if (> (howmanycol L Pos 1) 1) 
                #f ;if more than 1 assignemnet in col, return false
                (samecolassign L (+ Pos 1)))))
     (define (samecolassignzero L Pos)
        (if (= Pos (length L))
            #t
            (if (> (howmanycol L Pos 0) 1) 
                #f ;if more than 1 assignemnet in col, return false
                (samecolassignzero L (+ Pos 1)))))
     (define (samerowassignzero L)
       (if (null? L)
           #t
           (if (> (howmanyrow (car L) 0) 1)
               #f ;if more than 1 assignment in a row, return false
               (samerowassignzero (cdr L)))));else keep checking
               
         (if (= (howmanytotal L 1) (length L));If number if assignements is equal to matrix size
             (if (samerowassign L) ;Makes sure ones are not in same row
                 (if (samecolassign L 0) ;Makes sure ones are not in same col
                     #t ;if selections are not in the same row or col its true
                     #f) 
                 #f)
             (if (= (+ (howmanytotal L 1) (howmanytotal L 0)) (length L))
                 (if (samerowassign L) ;Makes sure ones are not in same row
                     (if (samecolassign L 0) ;Makes sure ones are not in same row
                         (if (samerowassignzero L) ;Makes sure zeroes are not in same row
                             (if (samecolassignzero L 0) ;Makers sure zeroes are not in same column
                                 #t
                                 #f)
                             #f) ;if selections are not in the same row or col its true
                         #f) 
                     #f)
                 #f)))


;Function that checks if there are correct number of lines covering matrix
;if there are same number all 1's except for 1
(define (assigned4? L)
    (if (= (howmanytotal L 0) 0); If no zeroes, return false
      #f
     (if (= (howmanytotal L 1) (- (length L) 1))
         #t; return true
         #f)));return false



;Function that checks if there are correct number of lines covering matrix part 2
;if there are 1s and 0s, but can make combinations
(define (assigned2? L)
  ;Function that checks if each row has same number of zeros as N
  (define (equalzeroes? L N) 
     (if (null? L);End of list return true
         #t
         (if (contains (car L) 0) ;if row contains zeroes
             (if (= (howmanyrow (car L) 0) N) ;if number of zeroes is equal to given value N
                 (equalzeroes? (cdr L) N);If true, check next row
                 #f);else, return false
             (equalzeroes? (cdr L) N)))); loop
  ;Main function
  (if (= (howmanytotal L 0) 0);if no zeros found, return false
      #f
     (if (= (modulo (howmanytotal L 0) (- (length L) (howmanytotal L 1))) 0);If missing assignement number divides total number of zeros
         (if (equalzeroes? L (/ (howmanytotal L 0) (- (length L) (howmanytotal L 1))));check if rows have correct number of zeros
              #t ;if so, return true
              #f);else return false
         #f)));else total zeroes not divisible, return false



;Function that checks if there are correct number of lines covering matrix part 3
;If there are 2s and 0s but can make combinations
(define (assigned3? L)
  (if (= (howmanytotal L 0) 0); If no zeroes, return false
      #f
     (if (= (+ (howmanytotal L 0) (howmanytotal L 2)) (* (length L) (length L)));If zeroes and twos together the size of grid
         #t; return true
         #f)));return false


;Function that checks if all found in the matrix are zeroes
(define (allzeroes L)
       (if (= (howmanytotal L 0) (* (length L) (length L)));if total zeroes is same as all grid points
           #t ;return true
           #f));else return false


;Function that gets all the assigned values when 1s are equal to size of matrix
(define (findAssigned L M Pos C)
          (if (= Pos (length L));done when reached length of matrix
               C
               (if (allzeroes M);If all zeroes
                   (findAssigned L M (+ Pos 1) (append C (list (list (lookup-row Pos) (lookup-col2 Pos)))));add diagonally
                   (if (contains (list-ref M Pos) 1); If 1 is founf add it to assignment for that row
                       (findAssigned L M (+ Pos 1) (append C (list (list (lookup-row Pos) (lookup-col2 (index-of (list-ref M Pos) 1))))));Add 1 as assignment
                       (if (contains (list-ref M Pos) 0);Else if 0 is found
                           (findAssigned L M (+ Pos 1) (append C (list (list (lookup-row Pos) (lookup-col2(index-of (list-ref M Pos) 0))))));Add 0 as assignment 
                           (findAssigned L M (+ Pos 1) C))))));If row doesnt have 0 either, loop

;Function number 2 that gets all the assigned values when not all are 1s
;Keeps track of checked rows
(define (findAssigned2 L M Pos C Pos2 Track)
          (if (= Pos (length L)) ;done when reached length of matrix
               C
               (if (allzeroes M) ;If all are zeroes
                   (findAssigned2 L M (+ Pos 1) (append C (list (list (lookup-row Pos) (lookup-col2 Pos)))) Pos2 Track);add diagonally
                   (if (contains (list-ref M Pos) 1) ;If 1 is found add it to assignement for that row
                       (findAssigned2 L M (+ Pos 1) (append C (list (list (lookup-row Pos) (lookup-col2 (index-of (list-ref M Pos) 1))))) Pos2 Track)
                       (if (contains (list-ref M Pos) 0); Else if 0 is found
                           (if (contains Track (list-ref (indexes-of (list-ref M Pos) 0)(modulo Pos2 (length (indexes-of (list-ref M Pos) 0)))));Check if current row has already been added, its tracked
                               (findAssigned2 L M Pos C (+ Pos2 1) Track);If row is checked meaning ist tracked,increment to get a new row
                               (findAssigned2 L M (+ Pos 1) (append C (list (list (lookup-row Pos) (lookup-col2(list-ref (indexes-of (list-ref M Pos) 0) (modulo Pos2 (length (indexes-of (list-ref M Pos) 0)))))))) (+ Pos2 1) (append Track (list (list-ref (indexes-of (list-ref M Pos) 0)(modulo Pos2 (length (indexes-of (list-ref M Pos) 0))))))))
                               (findAssigned2 L M (+ Pos 1) C Pos2 Track))))));If row doesnt contain 0, loop

;Function number 3 that gets all the assigned values when none are 1s
;Keeps track of checked rows 
(define (findAssigned3 L M Pos Done C Pos2 Track Zeros)
          (if (= Done (length L)) ;done when length of matriz has been reached
              (sort C #:key car string<?) ; sort final assignments by letter
              (if (contains (list-ref M Pos) 0) ;if row contains zeros
                     (if (contains Track (list-ref (indexes-of (list-ref M Pos) 0)(modulo Pos2 (length (indexes-of (list-ref M Pos) 0)))));Check if current row has already been checked, its tracked
                            (findAssigned3 L M Pos Done C (+ Pos2 1) Track Zeros);If row is checked meaning its in tracked, increment to get a new row
                            (findAssigned3 L M (leastzeros M 0 (append Zeros (list Pos)) 0 -1) (+ Done 1) (append C (list (list (lookup-row Pos) (lookup-col2(list-ref (indexes-of (list-ref M Pos) 0) (modulo Pos2 (length (indexes-of (list-ref M Pos) 0)))))))) (+ Pos2 1) (append Track (list (list-ref (indexes-of (list-ref M Pos) 0)(modulo Pos2 (length (indexes-of (list-ref M Pos) 0)))))) (append Zeros (list Pos))))
                     (findAssigned3 L M Pos (+ Done 1) C Pos2 Track)))) ;If row doesnt contain 0, loop
              


;Function that does optimal assignments
(define (optAssign L M OG)
  (display "Current converted Matrix: ")(newline)
  (display "1: selected zero (covered)")(newline)
  (display "-1: zero (covered)")(newline)
  (display "2: uncovered")(newline)
  (display "3: covered once")(newline)
  (display "4: covered twice")(newline)(newline)
  (displaymatrix (tempmatrix L))
  (newline)
      (display "Step 3: Testing for Optimal Assignment")
      (newline)
      (display "Row Scanning")
      (newline)
      (let ((rowscanned(rowScanning L M 0)));scan rows for single zeros, if so mark columns
            (displaymatrix rowscanned)
            (newline)
            (display "Column Scanning")
            (newline)
            (let ((colscanned(colScanning L rowscanned 0)));scan columns for single zeroes, if so mark rows
                 (displaymatrix colscanned)
                 (newline)
                 (if (assigned? colscanned) ;check condition 1 if its assigned, if so find assigned values
                     (begin (display "Optimal Assignments Found!")(newline) (findAssigned OG colscanned 0 '()))

                     (if (assigned2? colscanned);check condition 2 if its assigned, if so find assigned values
                          (begin (display "Optimal Assignments Found!!")(newline) (findAssigned2 OG colscanned 0 '() 0 '()))

                          (if(assigned3? colscanned);check condition 3 if its assigned, if so find assigned values
                                (begin (display "Optimal Assignments Found!!!")(newline) (findAssigned3 OG colscanned (leastzeros colscanned 0 '() 0 -1) 0 '() 0 '() '()))

                                (begin ;If no assignments found, shift zeroes, with smallest uncovered and loop back to step 3
                                  (if (= (howmanytotal colscanned 2) 0) ;if no more uncovered
                                      (begin (display "Optimal Assignments Found") (newline)(findAssigned OG colscanned 0 '()));found
                                      (begin (display "No Optimal Assignments");else shift zeroes
                                             (newline)(newline)
                                             (display "Step 4: Shifting Zeroes")
                                             (newline)
                                             (display "Smallest Uncovered: ")(display (smallestUncovered L colscanned -1))(newline)(newline)
                                             (optAssign (shiftzeroes L colscanned (smallestUncovered L colscanned -1) '()) (tempmatrix (shiftzeroes L colscanned (smallestUncovered L colscanned -1) '())) OG)
                           )))))))))
           
            

;Main Hungarian Algorithm function that performs algorithm and saves optimal
;assignment in a file 
(define (hungarianMatch L savefile)
       (display "Initial Matrix")
       (newline)
       (displaymatrix L)
       (newline)
       (display "Step 1: Row Reduction")
       (newline)
       (let ((rowred (rowReduction L))) ;reduce row
             (displaymatrix rowred)
             (newline)
             (display "Step 2: Column Reduction")
             (newline)
             (let ((colred (colReduction rowred (-(length L)1)))) ;reduce column
                   (displaymatrix colred)
                   (newline)
                   (proc-out-file savefile ;saves file
                      (lambda (p)
                        (let ((assignmentlist(optAssign colred (tempmatrix colred) L)));get assignment and save file
                             (let f ((l assignmentlist))
                                   (if (not (null? l))
                                    (begin
                                      (write (string->symbol (first(car l))) p);add row
                                      (write #\, p) ;add comma
                                      (write (string->symbol (second(car l))) p);add col
                                      (newline p);add space to go to next assignment
                                      (f (cdr l)))
                                    null))
                        assignmentlist))))));Outputs assignments as well

;Function to get column names from CSV file
(define (getColumnNames file N)
  (define (readFile2 file)
    (let ((p (open-input-file file)))
      (let f ((x (read p)))
        (if (eof-object? x) ; check for eof
            (begin 
              (close-input-port p)
              '())
            ;Else
            (if (number?(to-string x))
                (cons (to-string x) (f (read p)))
                ;else if not string
                (cons (to-string x) (f (read p)))))
        )))
     (take (readFile2 file) N))

;Function that makes list of numbers from 0 - N
(define (makelist N Start C) 
  (if (= Start N)
      C
      (makelist N (+ Start 1) (append C (list Start)))))

(define lookup-col ;Creates lookup table with the roman symbols mapped with numerical values as follows for COLUMNS
      (mapping (makelist (length  (getColumnNames filename (length (readCostMatrixCSV filename)))) 0 '())
              (getColumnNames filename (length (readCostMatrixCSV filename)))))


;Remainder of program that performs procedure as shown in the assignment  
(hungarianMatch(readCostMatrixCSV filename) (string-append (string-append "tracker_scheme_" (number->string (length (readCostMatrixCSV filename)))) ".csv"))
(newline)
(display "*OUTPUT FILE SAVED TO THIS DIRECTORY*")(newline)
(display "Feel free to try manually with the function as stated in the Assignment")

;Completed 7/24/2020 8:00PM


