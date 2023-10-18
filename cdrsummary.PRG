
&& This is the testing branch


CLOSE DATABASES all

cdr=GETFILE("dbf","CDR File")

IF EMPTY(cdr)
	RETURN
ENDIF

USE (cdr) ALIAS cdr
SELECT customer,space(50) as descr,COUNT(*) as noofcalls,SUM(mymount) as amount,0000 as channels,0.00 as costeach,0.00 as chantot FROM cdr ORDER BY customer GROUP BY customer INTO TABLE JUSTPATH(cdr)+"\summary"

USE g:\dll\sites IN 0

sele summary
SCAN
	SELECT sites
	LOCATE FOR allt(summary.customer)=ALLTRIM(sites.endpoint)
	tdesc	=	IIF(FOUND(),sites.name,"CUSTOMER NOT FOUND")
	SELECT summary
	REPLACE descr WITH tdesc
ENDSCAN

SELECT sites
SCAN
	SELECT summary
	LOCATE FOR allt(summary.customer)=ALLTRIM(sites.endpoint)
	IF !FOUND()
		APPEND BLANK
		REPLACE customer WITH sites.endpoint,descr WITH ALLTRIM(sites.name)+" NO CALL DETAIL RECORDS FOUND",channels WITH sites.channels,costeach WITH sites.cost,chantot with sites.channels*sites.cost
	ELSE
		REPLACE channels WITH sites.channels,costeach WITH sites.cost,chantot with sites.channels*sites.cost
	ENDIF
ENDSCAN

SELECT summary 
COPY TO JUSTPATH(cdr)+"\summary" TYPE csv
WAIT WINDOW "All Calls"
BROWSE


SELECT * FROM summary WHERE descr<>"CUSTOMER NOT FOUND" INTO TABLE JUSTPATH(cdr)+"\billing"

COPY TO JUSTPATH(cdr)+"\billing" TYPE csv
WAIT WINDOW "Billing"
BROWSE
