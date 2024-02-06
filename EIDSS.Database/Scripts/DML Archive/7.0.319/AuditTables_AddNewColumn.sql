ALTER TABLE tauDataAuditEvent
ADD strMainObject NVARCHAR(200) NULL;

ALTER TABLE tauDataAuditDetailCreate
ADD strObject NVARCHAR(200) NULL;

ALTER TABLE tauDataAuditDetailDelete
ADD strObject NVARCHAR(200) NULL;

ALTER TABLE tauDataAuditDetailRestore
ADD strObject NVARCHAR(200) NULL;

ALTER TABLE tauDataAuditDetailUpdate
ADD strObject NVARCHAR(200) NULL;