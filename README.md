MKO
===

```lisp
("list" "of" "items")
["array" "of" "items"]
{hash:"map" object:"type"}

;; The use macro will require the given module and
;; name the value to whatever the module name is.
(use 'fs)

;; You can also use a regular require
(fs (require "fs"))

;; You can define functions
(fun add-numbers (a b)
                 (add a b))

;; You can abstract error messages away from the CPS
;; pattern
(cps function-name (arg-a arg-b)
                   (call other function)
                   (fs.read-file "myfile" (cps (result)
                                               (+ 1 result))))

;; Above CPS-example is equal to
(fun my-function (arg-a arg-b)
                 (fs.read-file "myfile" (fun (err result)
                                             (if err
                                                 (do-something-about err)
                                                 (+ 1 result)))))

;; You can call functions in series or paralell and
;; collect the result
(ser
    my-function-a
    my-function-b
    (fun (results)
         (console.log results)))

(par
    my-function-a
    my-function-b
    (fun (results)
         (console.log results)))

;; Currying
(add-5 (add 5))
(eleven (add-5 6))

;; You can map over an array
(new-array (map array (fun (item)
                           (item field))))

(ser-map files fs.read-file (fun (results)
                                 (console.log results)))

(new-array (chain array
           (filter (fun (item)
                        (eq item.size 5)))
           (map (fun (item)
                     (item.size)))))

