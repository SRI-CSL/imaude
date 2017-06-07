******************************************************************************

The IMaude core (load-imaude-core.maude) provides the basic data structures and
rules to support building interaction environments and interacting with the IOP
filemanager and socketfactory actors.

******************************************************************************

IMaude uses the loop mode user interface.
This is the reason that commands are all enclosed in parentheses

IMaude can be run directly in Maude or using the IOP framework.
See doc-using.txt for examples.

******************************************************************************

IMaude is request (task) based with request scheduler rules to manage the
request queue.  This is done to support asynchronous interaction with
external objects.  Incoming requests are queued and enabled requests are
scheduled.   In general a request has an identifier, an argument, and a
continuation.   The continuation is a request list.  Requests submitted 
by the user have the form (reqid toks)  where reqid is the request identifier
and toks is the argument, a QidList, the continuation is nil.   
There are also a few commands that handled without 
being queued, this is largely for debugging, to examine the IMaude state.


The IMaude state has 5 components
   Control  --- current request or `ready'
   Wait4Set --- listeners for messages comming from external actors
            --- or for replies to requests (callbacks)
   RequestQ --- a list of pending requests
   ESet     --- an environment associating a descriptor to an annotated value.
   Log      --- a list of messages (error, event log, messages)
            ---  queued for inspection by user

Environment entries have the form e(etype,ids,notes,val). etype is a qid,
conventionally naming the subtype of val, and ids uniquely identifies the entry
amongst those of type etype. Together (etype,ids) form the descriptor. notes is
the entry annotation, a possibly empty map from strings to values, used to
provide information about the entry, such as its source or some computed or
specified properties. val is of sort Val which is essentially a union of
different value types. Built in value types are QVal, SVal and TVal. Elements of
QVal have the form ql(qs) where qs is a QidList. Elements of SVal have the form
sv(s) where s is a String. Elements of TVal have the form tm(modname,term) where
modname is a Qid nameing a module, and term is the metarepresentation of a term
in that module.

Associated to each state component data type are functions to show 
(print as a qidlist) and parse the printed qidlist elements of the data type.
They extend printing and parsing functions for values and notes
and use Maude's metaPrettyPrint and metaParse for meta represented terms.


Here is a summary of the files 

foo.maude              --- example base level module for testing REWRITE
idata.maude            --- the basic data structures for IMaude state
idata-io.maude         --- sho   
istate.maude           --- state management 
scheduler.maude        --- request scheduler
rewrite.maude          --- rewrite requests

load-imaude-test.maude  --- to play with rewriting over foo.maude

--- for use with iop 
input.txt             
startup.txt
filemanager.maude      --- file reading/writing  save/restore state -- needs iop
iutil.maude            --- interacting with graphics2d
lib.lsp                --- a jlambda library
sockets.maude          --- communication via sockets
load-imaude-core.maude  


These use modules from the Util and Meta libraries:

mymetaterm.maude  --- manipulating terms
mymetastatement.maude  
mymetaanalysis.maude --- equations and rules
mymetacnv.maude   --- converting between 
                  ----- qids and their meta representation
                  ----- nats and their meta representation

IMaude uses the loop mode user interface.
This is the reason that commands are all enclosed in parentheses

******************************************************************************
*** IMAUDE-STATE
*** state management --- show and reset commands for each component 
*** commands are handled immediately, under all conditions,
*** the show and resent commands all print information for the user
******************************************************************************
(show control)
(reset control)

(show wait4s)
(reset wait4s)

(show requests)
(reset requests)

(show log)
(reset log)

(show eset)
(reset eset)

(reset all )
(show cstate) --- shows control, wait4s, and requests

(show summary) --- lists the <type> <ids> for each entry but not the value
(show entry <type> <vname> <ids>) 
   --- shows the value of the entry identified by <type> <vname> <ids>
   --- there should be at most one, but if more one will be picked
(remove entry <type> <vname> <ids>)
   --- removes the identified entry
(copy entry <type> (<newids>) <oldids>)
   --- copies entry defined by <type> <oldids> into <type> <newids>


******************************************************************************
**** SCHEDULER 
**** In addition to queing and scheduling tasks the
**** scheduler handles logging requests and a request to 
**** print to the user.
******************************************************************************
(logreq toks) 
   -- always enabled
   -- results in  log('report, toks, dummy) being added to the log

(foruser toks) 
   -- always enabled
   -- results in toks being sent to user from maude 

******************************************************************************
**** REWRITE
**** The rewrite module defines requests for interacting with an underlying
**** object module. Terms can be reduced and rewritten using the default
**** interpreter or specifying a list of rules to apply.
**** The results are saved in the environment for futher processing.  
**** Also, functions can be applied to arguments stored in the environment.
**** In all cases the continuation is queued once the environment is updated.
**** The user forms of these requests are documented below
******************************************************************************
*** naming things
******************************************************************************

(setqc <vname> <qids>) 
 --- makes an entry e('qval, <vname>, ql(<qids>))

(setsc <vname> <qids>) 
 --- makes an entry e('sval, <vname>, sv(qidl2str(<qids>)))

(letc <vname> <modulename>  <sort>  <exp>)
 --- attempts to parse (the qids that result from tokenizing <exp>) 
 --- in the module named by <modulename> as an element of sort <sort>. 
 --- If sucessful, the resulting term is reduced to canonical form, res,
 --- and stored as an entry e('tval, <vname>, tm(<modulename> res))

******************************************************************************
**** operating on QidLists and Strings
******************************************************************************

(exec <type> <vname> <op> <toks>)
  --- <type> is q or s -- indicates the arg type
  --- <vname> is where to store the result
  --- <op> the operation
  --- <toks> where to find the args
  --- meaningful combinations
        q|s <vname> + <toks>  --- concatenation
        q|s <vname> len <toks>  --- length stored as qid
        q|s <vname> sub <start> <len> <toks>  --- subseq 
         q  <vname> q2s <toks>   --- convert qidl to str
         s  <vname> s2q <toks>   --- convert str to qidl 

******************************************************************************
*** rewriting 
******************************************************************************
(rewritec <nat> <vname> [<newvname>])
   --- rewrites the term stored as 'tval <vname> 
   --- using at most <nat> rewrites (rule applications)
   --- stores the result back in <newvname> if present ow in <vname>

(frewritec <nat> <fnat> <vname> [<newvname>])
   --- as for rewritec, but uses frewrite with bound <nat> and local bound <fnat>

(applyc <modname> <vname> <fname> <arg1> ... <argn>) 
  --- The function <fname> is applied to argements stored
  --- (using let) in <arg1> ... <argn> in the module named by <modname>
  --- and reduced to canonical form, res.  
  --- The result is saved in <vname>, 
  ---    i.e. an entry e('tval,<vname>,tm(<modname>,res))


(applyrulesc <vname> <rname> <rids>)
 --- tries to apply each rule named in <rids> to the term stored in <vname>
 --- and stores the result in <rname> 
 --- rules that don't apply are skipped


(listrulesc <vname> <rname>)
   --- stores (rid num)* as 'qval <rname> where num is qid representing
       the number of instances of rid that apply to the term in 'tval <vname>
 

(applyxrulesc <vname> <rname> q )
 --- tries to apply each rule named in the value stored in q
      to the term stored in <vname>
 --- and stores the result in <rname> 
 --- rules that don't apply are skipped


******************************************************************************
*****  Using IOP actors
******************************************************************************
In the following we document the requests for interacting with
IOP actors.  Most can be invoked from the IOP window, but 
the intent is that they be invoked from another request, as
they often require a non-trivial continuation to be useful.

(reqid args) --- indicates what can be sent by the user via the IOP
interface req(reqid,eval,reqQ) is a request with rules for processing.  reqQ
is the continuation, which is queued with the results of processing the
request.  Core user requests other than the interactive commands above get
queued with nil contination and generate no addition to the LOOP mode output
queue.  One must write special versions to have a non-trivial continuation.

******************************************************************************
*** file manager requests
******************************************************************************

(filewrite <fname> <mode> <toks>)
  ---  enabled whenenver IMaude is not waiting for the filemanager
  ---  when the request is processed the qidlist toks is written to the
  ---  file <fname> using append mode if <mode> is 'A and overwrite mode owise
  ---  The filemanagers acknowlegement is logged.
  ---  A Maude generated request may specify a continuation request
  ---  for additional processing of the filemanager's reply


(fileread <fname> <vname>)
  ---  enabled whenenver IMaude is not waiting for the filemanager
  ---  when the request is processed the file <fname> is read and the reply
  ---  contents <fname> <toks>
  ---  or
  ---  readFailure <fname>
  ---  is stored as a QVal with identifier <vname> for further processing

**** saving state

(save <fname> <mode> <stype> <toks>)
  --- always enabled
  --- queues a filewrite request with parameters <fname> <mode> and a qidlist
  --- obtained by `showing' the specified part of the IMaude state
  --- <stype> can be control, requests, wait4s, eset, entry, or log.
  --- <toks> is ignored except when <stype> is entry, then <toks> 
  --- is used to be an entry descriptor.    


(restore <fname> <vname> <stype> <toks>)
  --- always enabled
  --- which inturn queues a fileread request with parameters <fname> <vname>
  --- and a continuation that parses the qidlist stored in <vname> 
  --- as <stype> <toks> and restores the corresponding state component.

******************************************************************************
**** !!!THIS IS PROBABLY OUT OF DATE!!!
******************************************************************************
*** socketfactory requests
******************************************************************************
(openlistener port)
  --- queues req('openlistener,ql(port), nil)
  --- processing req('openlistener,ql(port), reqQ0)
  --- asks socketfactory to open a listener on port
  --- socketfactory reply is sent to the continuation request(s)
  --- the reply has the form
  ---  (<sender> 'socketfactory 'openListenerOK <listener name>)
  ---   or
  ---  (<sender> 'socketfactory 'openListenerFailure)
To be usefule the continuation should at least 
add a wait4(<listener name>, ql(port), reqQ) to the
wait4 part of the state, where reqQ does what ever is
to be done with new connection requests.
The listener will be one of the IOP actors that you can talk to
directly via the IOP window, so can close it.
See the nodeenv mode of interaction in the MobileMaude prototype
for an example.

(openclient host port)
--- queues req('openclient,ql(host port), nil)
--- processing req('openclient,ql(host port), reqQ0) 
  --- asks the socketfactory to open a client connenction to host on port
  --- the socketfactory reply is sent to the continuation request(s) reqQ0
  --- the reply has the form
  ---   (<sender> 'socketfactory 'openClientOK <client socket name>)
  ---   or
  ---   (<sender> 'socketfactory 'openClientFailure)
The client socket will appear in the list of actors in the IOP window
so the user can send messages to the socket (read,write, close) directly.

(socketwrite socket toks)
  --- queues req('socketwrite, ql(socket toks), nil)
  --- processing req('socketread, ql(socket), reqQ0)
  --- sends a write request to the socket and 
  --- passes the reply to the continuation request(s) reqQ0
  --- the reply has the form
  ---   (<sender> socket 'writeOK <no of bytes written>)
  ---   or
  ---   (<sender> socket 'writeFailure)

(socketread socket toks)
  ---  queues req('socketread,ql(socket toks),nil)
  --- processing req('socketread,ql(socket toks),reqQ0)
  --- sends a read request to the socket and 
  --- passes the reply to the continuation request(s) reqQ0
  --- the reply has the form
  ---   (<sender> socket 'readOK <no of bytes reaed>  toks )
  ---   or
  ---   (<sender> socket 'readFailure)
Again the tokens are lost if there is no coninuation to take them
Its easy to write user friendly commands that use this
and eith print the result to stdout or save them in a log or 
environment entry

(socketclose socket)
  --- queues req('socketclose, ql(socket), nil)
  --- processing req('socketclose, ql(socket), reqQ0)
  --- sends a close message to socket and
  --- passes the reply to reqQ0
  --- the reply has the form
  ---   (<sender> socket 'closeOK)
  ---   or
  ---   (<sender> socket 'closeFailure)
socket can be clientsocket or listener socket -- API is the same



