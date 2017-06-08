
(let (
      (vmId "vm")
      (vm (object ("g2d.jlambda.Attributable")))
      (frame (object ("javax.swing.JFrame" "Prancing Pony II")))

      (apples (object ("javax.swing.JLabel")))
      (cakes (object ("javax.swing.JLabel")))
      (dollars (object ("javax.swing.JLabel")))
      (quarters (object ("javax.swing.JLabel")))
      (status (object ("javax.swing.JLabel"    "Deficit:  0.0")))

      (menu (object ("javax.swing.JMenuBar")))
      (credit (object ("javax.swing.JMenu" "Insert Money")))
      (debit (object ("javax.swing.JMenu" "Buy Item")))
      (dollar (object ("javax.swing.JMenuItem" "$")))
      (quarter (object ("javax.swing.JMenuItem" "$/4")))
      (change (object ("javax.swing.JMenuItem" "qqqq->$")))
      (apple (object ("javax.swing.JMenuItem" "Apple")))
      (cake  (object ("javax.swing.JMenuItem" "Cake")))

      ;;closures to be installed as ActionListener's
      (dollarClosure  (lambda (self e) 
			(invoke java.lang.System.err "println" "\nadded $")
			(apply vendDebit (float 1))
			;;  (sinvoke "g2d.util.ActorMsg" "send" "maude" vmId "applyrulesc vm vm add-$")
			(sinvoke "g2d.util.ActorMsg" "send" "maude" vmId 
				 (concat "vend"  " " "add-$"))
			(apply vendStatus)
			))
      (quarterClosure  (lambda (self e)
			 (invoke java.lang.System.err "println" "\nadded $/4")
			 (apply vendDebit (float 0.25))
			 ;; (sinvoke "g2d.util.ActorMsg" "send" "maude" vmId "applyrulesc vm vm add-q")
			 (sinvoke "g2d.util.ActorMsg" "send" "maude" vmId 
				  (concat "vend"  " " "add-q"))
			 (apply vendStatus)
			 ))
      (changeClosure  (lambda (self e)
			(invoke java.lang.System.err "println" "\naqqqq->$")
			(sinvoke "g2d.util.ActorMsg" "send" "maude" vmId 
				 (concat "vend"  " " "change"))
			))
      (appleClosure  (lambda (self e) 
		       (invoke java.lang.System.err "println" "\nbought apple")
		       ;;  (sinvoke "g2d.util.ActorMsg" "send" "maude" vmId "applyrulesc vm vm buy-a")
		       (sinvoke "g2d.util.ActorMsg" "send" "maude" vmId 
				(concat "vend"  " " "buy-a"))
		       ))
      (cakeClosure (lambda (self e) 
		     (invoke java.lang.System.err "println" "\nbought cake")
		     ;; (sinvoke "g2d.util.ActorMsg" "send" "maude" vmId "applyrulesc vm vm buy-c")
		     (sinvoke "g2d.util.ActorMsg" "send" "maude" vmId 
			      (concat "vend"  " " "buy-c"))
		     )) ; cakeClosure
      ) ;; letbindings
  
  ;;setup the frame
  (invoke frame "setLayout" (object ("java.awt.GridLayout" (int 5) (int 1))))
  (invoke frame "add" apples)
  (invoke frame "add" cakes)
  (invoke frame "add" dollars)
  (invoke frame "add" quarters)
  (invoke frame "add" status)
  ;; installing the closures as ActionListener's
  (invoke dollar "addActionListener" 
	  (object ("g2d.closure.ClosureActionListener" dollarClosure)))
  (invoke quarter "addActionListener" 
	  (object ("g2d.closure.ClosureActionListener" quarterClosure)))
  (invoke change "addActionListener" 
	  (object ("g2d.closure.ClosureActionListener" changeClosure)))
  (invoke apple "addActionListener" 
	  (object ("g2d.closure.ClosureActionListener" appleClosure)))
  (invoke cake "addActionListener" 
	  (object ("g2d.closure.ClosureActionListener" cakeClosure)))
  (invoke credit "add" dollar)
  (invoke credit "add" quarter)
  (invoke credit "add" change)
  (invoke debit "add" apple)
  (invoke debit "add" cake)
  (invoke menu "add" credit)
  (invoke menu "add" debit)
  (invoke frame "setJMenuBar" menu)
  
  (invoke vm "setUID" vmId)
  
  (setAttr vm 
	   "GUInterface" 
	   (lambda (d q a c) 
	     (seq 
	      (invoke java.lang.System.err "println" (concat "d = " d))
	      (invoke apples   "setText"  (apply makeLabel "Apples:    "  "A " a))
	      (invoke cakes    "setText"  (apply makeLabel "Cakes:     "  "C " c))
	      (invoke dollars  "setText"  (apply makeLabel "Dollars:   "  "$ " d))
	      (invoke quarters "setText"  (apply makeLabel "Quarters:  "  "q " q))
	      (apply vendStatus))))
  
  (define vendUpdate (vname d q a c) 
    (apply (getAttr (fetch vname) "GUInterface" (object null)) d q a c)) 
  
  
  (define vendDebit (amount) 
    (let ((vend (fetch vmId)))
      (setAttr vend "deficit" (+ (getAttr vend "deficit" (float 0)) amount))))
  
  (define vendStatus () 
    (let ((vend (fetch vmId))
	  (tally (getAttr vend "deficit" (float 0)))
	  (tstring (concat "Deficit:     " tally)))
      (seq 
       (invoke status "setText" tstring)
       )
      )
    )
  
  (define makeLabelAux (ch num result)
    (if (= num (int 0))
	result
      (apply makeLabelAux ch (- num (int 1)) (concat result " " ch))))
  
  
  (define makeLabel (prefix ch num)
    (concat prefix (apply makeLabelAux ch num "")))
  
  (setAttr vm "deficit"  (float 0))
  
  (apply vendUpdate vmId (int 0) (int 0) (int 0) (int 0))
  
  (invoke frame "setSize" (int 300) (int 200))
  (invoke frame "setVisible" (boolean true))
  
  )


