/*
    SQL to query process run details, similar to what you get in process monitor, and including message logs.
*/
WITH
    CTE_XLT AS  (
        /*
            get max effective dated translate values
        */
        SELECT
            XLT1.FIELDNAME
        ,   XLT1.FIELDVALUE
        ,   XLT1.XLATLONGNAME
        ,   XLT1.XLATSHORTNAME
        FROM
            PSXLATITEM  XLT1
        WHERE
            XLT1.FIELDNAME  IN  ('RUNSTATUS', 'DISTSTATUS')
        AND XLT1.EFF_STATUS =   'A'
        AND XLT1.EFFDT      =   (
                SELECT
                    MAX(XLT2.EFFDT)
                FROM
                    PSXLATITEM  XLT2
                WHERE
                    XLT2.FIELDNAME  =   XLT1.FIELDNAME
                AND XLT2.FIELDVALUE =   XLT1.FIELDVALUE
            )
    )
SELECT
    Q.PRCSINSTANCE
,   Q.RUNCNTLID
,   Q.PRCSTYPE
,   Q.PRCSNAME
,   Q.OPRID
,   Q.RUNDTTM
,   Q.RUNSTATUS
,   (
        SELECT
            XLT1.XLATLONGNAME
        FROM
            CTE_XLT XLT1
        WHERE
            XLT1.FIELDNAME  =   'RUNSTATUS'
        AND XLT1.FIELDVALUE =   Q.RUNSTATUS
    )                   AS  RUNSTATUS_DESCR
,   Q.DISTSTATUS
,   (
        SELECT
            XLT1.XLATSHORTNAME
        FROM
            CTE_XLT XLT1
        WHERE
            XLT1.FIELDNAME  =   'DISTSTATUS'
        AND XLT1.FIELDVALUE =   Q.DISTSTATUS
    )                   AS  DISTSTATUS_DESCR
,   Q.RECURNAME
,   Q.JOBINSTANCE
,   Q.PRCSJOBNAME
/*
    message log info
*/
,   LOGP.MESSAGE_SEQ
,   LOGP.PARM_SEQ
,   LOGP.MESSAGE_PARM
,   LOG.DTTM_STAMP_SEC
FROM
    PSPRCSQUE   Q
LEFT JOIN
    PS_MESSAGE_LOGPARM  LOGP
ON
    LOGP.PROCESS_INSTANCE   =   Q.PRCSINSTANCE
LEFT JOIN
    PS_MESSAGE_LOG  LOG
ON
    LOG.PROCESS_INSTANCE    =   LOGP.PROCESS_INSTANCE
AND LOG.MESSAGE_SEQ         =   LOGP.MESSAGE_SEQ
WHERE
    1           =   1
/*
    filter by process instance or process name
*/
-- AND Q.PRCSINSTANCE  =   :prcsInstance
-- AND Q.PRCSNAME  =   :prcsName
ORDER BY
    Q.PRCSINSTANCE      DESC
,   LOGP.MESSAGE_SEQ
,   LOGP.PARM_SEQ
;
