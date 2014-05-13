; Any identifier not yet declared in scope
; is represented by a function. That function
; takes a value. Any subsequent call to that
; function without arguments will return the
; value. An identifier can never change after
; once beeing set to a value.
(var-a 5)
(var-b "Some string")

; Macro fun defines functions
(fun-a (fun (x y)
            (variable-c 7)
            (7 * variable-c)))

; Any initialized identifier is a function
; that takes two arguments. First argument
; is the function to execute with the identifier
; as the first argument and the second argument
; as the second argument to the function.
(truthy (eq (sub var-a var-b)
            (var-a sub var-b)))

; Simple example of continuation pattern
(read-file file-name (fun (err result)
                          (console.log "Error output:")
                          (console.log err)
                          (console.log "Result output:")
                          (console.log result)))

; Async macro creates a function and apply a
; hidden callback function to the end of the
; argument list.

; The expect macro creates a function that
; injects a first argument to the function. It
; will also verify that the argument is non null
; before continue executing the function.
(async open-file (file-name)
                 ; If the first argument is null, it will call
                 ; the previously declared and hidden callback
                 ; function with the value of the first argument.
                 (read-file file-name (expect (result)
                                      ; The raise macro will call the hidden function
                                      ; with the argument as the hidden functions
                                      ; first argument.
                                      (raise "New error!")
                                      ; The report macro will call the previously
                                      ; declared and hidden callback with the first
                                      ; argument set to null. The rest of the
                                      ; arguments given to report will be appended
                                      ; to the callback.
                                      (report result))))

(open-file "my-file" (err result)
                     (console.log err)
                     (console.log result))

; Types
; ------
; number      0.1
; string      "Hello world!"
; regex       /hello/gi
; list        (a b c)        items can be of any type
; array       [a b c]        items can be of any type
; dictionary  {a:1 b:2 c:3}  items can be of any type
; tuple       |a b c|        items can be of any type
; function    t -> ()        t can be of any type

; Macros
; ------
; lambda
; async
; expect
; dontexpect
; report
; raise

; Functions
; ---------
; array/map
; array/reduce
; array/find
; array/reject
; array/push

; number/add
; number/sub
; number/div

; dict/set
; dict/get
; dict/keys
; dict/values

; list/car
; list/cdr
; list/cont

(pattern /test/gi)
(array-value [j k l])
(assoc-value {a:j b:k c:[q [another 3 inside] e]})

; Tests
(my-function (fun (argument-a argument-b)
                  "Nice description"
                  (argument-a sub argument-b)))

(fun my-function (arg-a arg-b)
     "Nice description meta data"
     (arg-a sub arg-b))

(my-function (fun (arg-a arg-b)
                  "Nice description"
                  (arg-a sub arg-b)))

(my-value 4)

(my-function (- (arg-a arg-b)
                "Description"
                (arg-a - arg-b)))

(my-macro (mac (body)
               (body cont 'fun)))

(pattern /test/gi)
(my-function 5 6)
(array-var [a b c d])
(my-module/array-var {a j
            b k
            c l
            d o})
(array-var <a b c d>)
