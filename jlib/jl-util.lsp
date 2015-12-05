;; jl-util.lsp

(define print2err (str) (invoke java.lang.System.err "println" str))

(define removeLast (str n)
 (invoke str "substring" (int 0) (- (invoke str "length") n))  
)
;; len 5 n 1 substr 0,4 chars upto but not including 4

;; replace by delete method
(define removeSBLast (strb n) (apply removeLast (invoke strb "toString") n))


(define ensureList (elt)
  (if (instanceof elt "java.util.List") elt (apply mkMt)))

(define ensureString (elt)
  (if (instanceof elt "java.lang.String") elt ""))

(define mkMtSet () (object ("java.util.HashSet")))
(define mkMtMap () (object ("java.util.HashMap")))
(define mkMt () (object ("java.util.ArrayList")))

;;; safe dget
(define dgetS (obj tag default)
  (if (instanceof obj "java.util.Map")
	  (let ((val (invoke obj "get" tag)))
		  (if (isobject val) val default) )
    default	))

(define dget (obj tag default)
  (let ((val (invoke obj "get" tag)))
    (if (isobject val) val default)  ))

(define mkSingle (x)
  (let ((res (object ("java.util.ArrayList"))))
    (invoke res "add" x)
    res ))

(define mkPair (x y)
  (let ((res (object ("java.util.ArrayList"))))
    (invoke res "add" x)
    (invoke res "add" y)
    res ))

(define mkTriple (x y z)
  (let ((res (object ("java.util.ArrayList"))))
    (invoke res "add" x)
    (invoke res "add" y)
    (invoke res "add" z)
    res ))

(define mkQuad (x y z w)
  (let ((res (object ("java.util.ArrayList"))))
    (invoke res "add" x)
    (invoke res "add" y)
    (invoke res "add" z)
    (invoke res "add" w)
    res ))

(define mkFive (x0 x1 x2 x3 x4)
 (let ((res (apply mkMt)))
   (invoke res "add" x0)	
   (invoke res "add" x1)	
   (invoke res "add" x2)	
   (invoke res "add" x3)	
   (invoke res "add" x4)	
	res
	))

;; objs is a collection of maps  
(define getByName (objs str)
  (apply getByNameX objs str (invoke objs "size") (int 0)))    

(define getByNameX (objs str len cur)
  (if (>= cur len)
    (object null)
    (let ((obj (invoke objs "get" cur)))
      (if (= (invoke obj  "get" "name") str)
      obj
      (apply getByNameX objs str len (+ cur (int 1)))
      ))
))

(define isArray (obj) (invoke (invoke obj "getClass") "isArray"))

(define isInt (str) 
  (try 
    (sinvoke "java.lang.Integer" "parseInt" str) 
    (boolean true) 
  (catch x (boolean false)) ))

(define isDouble (str) 
  (try 
    (sinvoke "java.lang.Double" "parseDouble" str) 
    (boolean true) 
  (catch x (boolean false)) ))

(define tryDouble (str fail) 
  (try 
    (sinvoke "java.lang.Double" "parseDouble" str) 
  (catch x fail) ))

(define tryInt (str fail) 
  (try 
    (sinvoke "java.lang.Integer" "parseInt" str) 
  (catch x fail) ))


(let ((patternstring "-??\\d+")
      (pattern (sinvoke "java.util.regex.Pattern" "compile" patternstring)))
  (define isint (query)
    (let ((matcher (invoke pattern "matcher" query)))
    (if (invoke matcher "matches")
	(boolean true)
      (boolean false)))))

(define subarray (arrl ixs)
  (let ((sarrl (object ("java.util.ArrayList"))))
   (for ix ixs (invoke sarrl "add" (invoke arrl "get" ix)))
   sarrl
))

;; works for any collection with a toArray method
(define sortArrl (arrl)
  (let ((arr (invoke arrl "toArray")))
    (sinvoke "java.util.Arrays" "sort" arr)
    (apply toArrl arr)
  ))

;; restrict hmap to keys
(define mapRestrict (map keys)
  (let ((hm (object ("java.util.HashMap"))))
   (for key keys 
     (let ((val (invoke map "get" key)))
       (if (isobject val) (invoke hm "put" key val))
       ))
  hm
  ))

(define mapRng (map dom)
 (let ((res (apply mkMt)))
   (for elt dom (apply arrlUnion res (apply dget map elt (apply mkMt))))
 ))

;; add elt to list associated to key
;; init with empty list if no association exists
(define mapAdd (map key elt)
  (let ((val0 (invoke map "get" key))
        (val (if (isobject val0) 
               val0
               (let ((val1 (object ("java.util.ArrayList"))))
                  (invoke map "put" key val1)
                  val1)))
        )
    (invoke val "add" elt)
))

;; add elt to list associated to key
;; init with empty list if no association exists
(define mapSetAdd (map key elt)
  (let ((val0 (invoke map "get" key))
        (val (if (isobject val0) 
               val0
               (let ((val1 (object ("java.util.ArrayList"))))
                  (invoke map "put" key val1)
                  val1)))
        )
    (apply setAdd val elt)
))


;; assume maps from symbols to arrlists
;; map0 will be updated
(define mapJoin (map0 map1)
 (for key (invoke map1 "keySet")
   (let ((vals (invoke map1 "get" key))) 
	   (if (> (invoke vals "size") (int 0))(apply mapJoinX map0 key vals))
	 )))

(define mapJoinX (map key newvals)
  (let ((val0 (invoke map "get" key))
        (val (if (isobject val0) 
               val0
               (let ((val1 (object ("java.util.ArrayList"))))
                  (invoke map "put" key val1)
                  val1)))
        )
    (apply arrlUnion val newvals)
		(boolean true)
))
	

(define mapget (map key default)
  (let ((v0 (invoke map "get" key)))
   (if (isobject v0)
	   v0
     (seq (invoke map "put" key default) default)
		 )
	))



;; print to std err elements selected by pfun using ofun
(define printlnArrP (arrl pfun ofun)
  (for elt arrl
     (if (apply pfun elt) 
        (invoke java.lang.System.err "println" (apply ofun elt)))
 ))

(define toArrl (col)
  (let ((arrl (object ("java.util.ArrayList"))))
    (for elt col (invoke arrl "add" elt))
    arrl
))

;; an arraylist of strings to a string array
(define arrlStr2arr (arrl) 
  (let ((len (invoke arrl "size"))
	      (arr (mkarray java.lang.String len)))
    (for ix len (aset arr ix (invoke arrl "get" ix)))				
    arr ))

(define intArr2arrl (arr)(apply mapArrl arr (lambda (elt) (concat elt ""))))

(define selectArrl (arrl pfun)
  (let ((sarrl (object ("java.util.ArrayList"))))
    (for elt arrl (if (apply pfun elt) (invoke sarrl "add" elt)))
    sarrl
 ))

(define andArrl (arrl pfun) 
  (try (for elt arrl 
    (if (not (apply pfun elt)) 
      (throw (object ("java.lang.Throwable"))) )) 
    (boolean true)
    (catch x (boolean false)) ))

(define orArrl (arrl pfun) 
  (try (for elt arrl 
    (if (apply pfun elt)
      (throw (object ("java.lang.Throwable"))) )) 
    (boolean false)
    (catch x (boolean true)) ))

(define mapArrl (arrl mfun)
  (let ((marrl (object ("java.util.ArrayList"))))
    (for elt arrl (invoke marrl "add" (apply mfun elt)))
    marrl
 ))

(define mapArrlSet (arrl mfun)
  (let ((marrl (object ("java.util.HashSet"))))
    (for elt arrl
      (let ((res (apply mfun elt)))
        (if (isobject res) (invoke marrl "add" res))))
    (apply toArrl marrl)
 ))

(define mapArrlSetS (arrl fun)(let ((marrl (object ("java.util.HashSet"))))   (for elt arrl (let ((res (apply mfun elt)))(if (isobject res) (invoke marrl "addAll" res)))) marrl))

;; elements of col0 that are not in col1
(define diff (col0 col1)
 (let ((res (apply mkMt)))
   (for elt col0 
     (if (not (invoke col1 "contains" elt)) (invoke res "add" elt) ))
   res
 ))

(define intersect (a0 a1) (apply diff a0 (apply diff a0 a1)))

(define intersects (a0 a1) (apply intersectsX a0 a1 (invoke a0 "size")(int 0)))
(define intersectsX (a0 a1 len cur)
  (if (>= cur len) 
    (boolean false)
    (if (invoke a1 "contains" (invoke a0 "get" cur))
      (boolean true)
      (apply intersectsX a0 a1 len (+ cur (int 1)))
    ) ))

;; does arrl1 contain every element of arrl0?
(define containsAll (arrl0 arrl1)
 (apply containsAllX arrl0 arrl1 (invoke arrl0 "size") (int 0))
)

(define containsAllX (arrl0 arrl1 len cur)
 (if (>= cur len)
   (boolean true)
   (if (invoke arrl1 "contains" (invoke arrl0 "get" cur))
	   (apply containsAllX arrl0 arrl1 len (+ cur (int 1)))
	   (boolean false)
	 )))

;; add elements of arrl1 to arrl0 if not there already
;; modifies arrl0
;; same result as arrUnion
(define uniAdd (arrl0 arrl1 len cur)
  (if (>= cur len)
      arrl0
      (let ((elt (invoke arrl1 "get" cur)))
        (if (not (invoke arrl0 "contains" elt)) (invoke arrl0 "add" elt))
        (apply uniAdd arrl0 arrl1 len (+ cur (int 1)))
      )
  ))
  
;; as uniAdd but not modifying arrl0	
  (define arrlSetAdd (arrl0 arrl1)
    (let ((arrl (object ("java.util.ArrayList"))))
      (invoke arrl "addAll" arrl0)
      (for elt arrl1 
           (if (not (invoke arrl0 "contains" elt)) (invoke arrl "add" elt)))
      arrl
  ))

(define setAdd (arrl elt)
  (if (not (invoke arrl "contains" elt)) (invoke arrl "add" elt))
  arrl
)

;; table is collecting values for key
(define add2tab (tab key val)
  (let ((v0 (invoke tab "get" key))
	      (v (if (isobject v0) 
				     v0 
      			 (let ((v1 (apply mkMt)))(invoke tab "put" key v1) v1)))
       	)
        (apply setAdd v  val)
	))
	
;; same fn as uniAdd
(define arrlUnion (arrl elts)
  (for elt elts (apply setAdd arrl elt))
  arrl
)
;; ptwise equality of arrays (not arraylists)
(define arrEq (arr0 arr1)
  (let ((len0 (lookup arr0 "length"))
        (len1 (lookup arr1 "length")))
  (if (= len0 len1)				
    (apply arrEqX arr0 arr1 len0 (int 0))
		(boolean false)
		)))
		
(define arrEqX (arr0 arr1 len cur)
  (if (>= cur len)
	  (boolean true)
		(if (= (aget arr0 cur) (aget arr1 cur))
		  (apply arrEqX arr0 arr1 len (+ cur (int 1)))
			(boolean false)
		)) )		


(define str2arrl (str) (apply mkSingle str))

(define split2arrl (elt chr) (apply toArrl (invoke elt "split" chr)))

(define slash2arrl (singleton) 
  (if (instanceof singleton "java.util.List")
   (if (> (invoke singleton "size") (int 0))
       (apply split2arrl (invoke singleton "get" (int 0) "/"))
       (object ("java.util.ArrayList"))
   )))
    
(define arrl2str (arrl sep)
 (if (isnull arrl) ""
  (let ((len (invoke arrl "size"))
        (strb (object ("java.lang.StringBuffer"))) )
   (if (= len (int 0)) ""
     (seq
       (invoke strb "append" (concat (invoke arrl "get" (int 0)) ""))
       (do ((cur (int 1) (+ cur (int 1))))
           ((>= cur len) (invoke strb "toString"))
           (invoke strb "append" (concat sep (invoke arrl "get" cur)))          
        ) ;;od
      ) ) 
  )))
  
(define titleCase (str)
  (let ((tail (invoke str "substring" (int 1) (invoke str "length")) )
        (head (invoke str "substring" (int 0) (int 1)))
       )
   (concat (invoke head "toUpperCase") 
           (invoke tail "toLowerCase")) 
  ))
  

(define lbrace "{")(define rbrace "}")
(define lbracket "[")(define rbracket "]")
(define lparen "(")(define rparen ")")
(define lp "(")(define rp ")")
(define lcurly "{") (define rcurly "}")
(define lsq "[") (define rsq "]")

;;;;;;;;;; reading/writing tables/rows

(define unsplit (row sep)
 (let ((strb (object ("java.lang.StringBuffer")))
       (len (invoke row "size")) )
  (invoke strb "append" (invoke row "get" (int 0)))
	(for ix len (if (> ix (int 0))(seq
	  (invoke strb "append" sep)
		(invoke strb "append" (invoke row "get" ix))
	)))
	(invoke strb "toString")
 ))
 
(define saveAsCSV (rows fname)(sinvoke "g2d.util.IO" "collection2File" rows fname (lambda (row) (apply unsplit row ","))   (boolean false)))

(define saveAs (rows fname sep)(sinvoke "g2d.util.IO" "collection2File" rows fname (lambda (row) (apply unsplit row sep))   (boolean false)))


(define loadFile (fname fun)
  (let ((arrl (object ("java.util.ArrayList"))))
   (sinvoke "g2d.util.IO" "file2Collection"
	            arrl fname fun (boolean true))
    arrl
))

(define loadCSV (fname)
 (apply loadFile fname
    (lambda (str) (apply toArrl (invoke str "split" ",")))))
		
(define loadTab (fname)
 (apply loadFile fname
    (lambda (str) (apply toArrl (invoke str "split" "\\t")))))

;; load chr separated table into [... (rowarr ...)  ...]
(define loadTable (fname chr) 
  (let ((arrl (object ("java.util.ArrayList"))))
   (sinvoke "g2d.util.IO" "file2Collection" arrl fname 
      (lambda (line) (invoke line "split" chr)) (boolean true))
    arrl
))

;;; reading writing maps  
;;; -> rows key,val
;; (apply hmap2tab fname hm ",")
(define saveMap (hm fname)
  (let ((arrl (apply mkMt)))
    (for key (invoke hm "keySet") 
      (invoke arrl "add" (apply mkPair key (invoke hm "get" key))))
      
    (sinvoke "g2d.util.IO" "collection2File" arrl fname
        (lambda (row) (concat (invoke row "get" (int 0)) "," 
                              (invoke row "get" (int 1)) ))
        (boolean false))
    ))    

;; hmap to tab file
(define hmap2tab (fname hmap sep)
  (let ((arrl (object ("java.util.ArrayList")))
        (keys (invoke hmap "keySet")) )
    (for key keys 
       (invoke arrl "add" (concat key sep (invoke hmap "get" key))))
    (sinvoke "g2d.util.IO" "collection2File" arrl fname 
        (object null)(boolean false))
 ))

;; hmap to tab file
(define hmap2tabSorted (fname hmap sep)
  (let ((arrl (object ("java.util.ArrayList")))
        (keys (apply sortArrl (invoke hmap "keySet")) ))
    (for key keys 
       (invoke arrl "add" (concat key sep (invoke hmap "get" key))))
    (sinvoke "g2d.util.IO" "collection2File" arrl fname 
        (object null)(boolean false))
 ))

;;; assume table key,val
(define loadMap (fname)
  (let ((arrl (apply loadCSV fname))
        (hm (apply mkMtMap))
       )
   (for row arrl
     (invoke hm "put" (invoke row "get" (int 0))(invoke row "get" (int 1)))
   )        
  hm
  ))    

;;; assume table key,val -- or key,
(define loadMapD (fname default)
  (let ((arrl (apply loadCSV fname))
        (hm (apply mkMtMap))
       )
   (for row arrl
	   (let ((key (invoke row "get" (int 0)))
		       (val (if (> (invoke row "size") (int 1))
					        (invoke row "get" (int 1))
								  default))
					 )
     (invoke hm "put" key val)
		 ))        
  hm
  ))    


(define loadMapT (fname)
  (let ((arrl (apply loadTab fname))
        (hm (apply mkMtMap))
       )
   (for row arrl (if (> (invoke row "size") (int 1))
     (invoke hm "put" (invoke row "get" (int 0))(invoke row "get" (int 1)))
   ))        
  hm
  ))    

(define loadMapInvT (fname)
  (let ((arrl (apply loadTab fname))
        (hm (apply mkMtMap))
       )
   (for row arrl (if (> (invoke row "size") (int 1))
     (invoke hm "put" (invoke row "get" (int 1))(invoke row "get" (int 0)))
   ))        
  hm
  ))    

;;; assume table key,val
(define loadMapInv (fname)
  (let ((arrl (apply loadCSV fname))
        (hm (apply mkMtMap))
       )
   (for row arrl
     (invoke hm "put" (invoke row "get" (int 1))(invoke row "get" (int 0)))
   )        
  hm
  ))    


;; convert table to map from col i to col j
(define tarrl2map (tarrl i j)
  (let ((hm (object ("java.util.HashMap")))
        (len (sinvoke "java.lang.Math" "max" i j))
        )
    (for ta tarrl (if (> (lookup ta "length") len)
                    (invoke hm "put" (aget ta i) (aget ta j))))
   hm))

;; write map of keys to string arrl 
;; key sep elt0 ... sep eltn-1
(define saveMap2Arrl (fname hmap sep)
  (apply saveMap2ArrlX fname hmap sep (boolean false)))

(define saveMap2ArrlX (fname hmap sep append?)
  (let ((arrl (apply mkMt))
        (keys (invoke hmap "keySet")) )
    (for key keys 
       (let ((strb (object ("java.lang.StringBuffer")))
             (vals (invoke hmap "get" key))
            )
         (invoke strb "append" key)
         (for val vals (invoke strb "append" (concat sep val)))
         (invoke arrl "add" (invoke strb "toString"))
         ))
    (sinvoke "g2d.util.IO" "collection2File" arrl fname 
        (object null) append?)
 ))

;; write map of keys to string arrl 
;; key sep elt0 ... sep eltn-1
(define saveMap2ArrlSorted (fname hmap sep)
  (apply saveMap2ArrlSortedX fname hmap sep (boolean false)))

(define saveMap2ArrlSortedX (fname hmap sep append?)
  (let ((arrl (apply mkMt))
        (keys (apply sortArrl (invoke hmap "keySet"))) )
      (for key keys 
       (let ((strb (object ("java.lang.StringBuffer")))
             (vals (invoke hmap "get" key))
            )
         (invoke strb "append" key)
         (for val vals (invoke strb "append" (concat sep val)))
         (invoke arrl "add" (invoke strb "toString"))
         ))
    (sinvoke "g2d.util.IO" "collection2File" arrl fname 
        (object null) append?)
 ))

;; loads file written by saveMap2Arrl
(define loadMap2Arrl (fname sep)
  (let ((arrl (apply mkMt))
        (hmap (object ("java.util.HashMap")))
        (fun (lambda (line) 
               (let ((parts (invoke line "split" sep))
                     (key (aget parts (int 0)))
                     (len (lookup parts "length"))
                     (val (apply mkMt))
                    )
                 (for ix len (if (> ix (int 0))
                    (invoke val "add" (aget parts ix))) )
                 (invoke hmap "put" key val)
                 key
                )))
          )
   (sinvoke "g2d.util.IO" "file2Collection" arrl fname fun (boolean true))
   hmap
 ))

;; assume row of strings
(define rowProject (row ixarr len)
 (let ((strb (object ("java.lang.StringBuffer"))))
   (invoke strb "append" (invoke row "get" (aget ixarr (int 0))))
	 (for ix len 
	   (if (> ix (int 0))
      (seq
   	    (invoke strb "append" "\t")
   	    (invoke strb "append" (invoke row "get" (aget ixarr ix)))
   	  ) 
    )) ))

 
(define saveTabTab (fname rows ixarr)
  (let ((len (lookup ixarr "length")))
   (sinvoke "g2d.util.IO" "collection2File" rows fname 
	 (lambda (row) (apply rowProject row ixarr len)) (boolean false))))


;; get values of elements in harr according to hm
(define hs2us (hm harr) 
  (let ((uarrl (object ("java.util.ArrayList"))))
   (for hid harr (invoke uarrl "add" (invoke hm "get" hid)))
   uarrl))

(define one-one (hm)
 (let ((vals (invoke hm "values"))
       (vset (object ("java.util.HashSet" vals)))
        )
    (= (invoke vals "size") (invoke vset "size"))
))

(define findDuplicates (arrl)
  (let ((seen (apply mkMt))
	      (dups (apply mkMt))
       	)
   (for elt arrl 
	   (if (invoke seen "contains" elt)
	     (invoke dups "add" elt)
   	   (invoke seen "add" elt)
	  ))
		dups				
	))
		
;; extract name conversion map from table tab with cols mix cix
(define tabNameCnv (tab mix cix)
 (let ((map (apply mkMtMap)))
   (for row (invoke tab "subList" (int 1) (invoke tab "size"))
	   (let ((mname (invoke row "get" mix)))
		  (if (isnull (invoke map "get" mname))
			  (invoke map "put" mname (invoke row "get" cix)) )
		 ))
   map
 ))

		
