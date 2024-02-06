

UPDATE [dbo].[trtBaseReference] 
SET [strDefault]=N'Can modify status of rejected/deleted sample' 
WHERE [idfsBaseReference] = 10094540 



UPDATE [dbo].[trtBaseReference] 
SET [strDefault]=N'GG Director (Vet)' 
WHERE [idfsBaseReference] = -529 

UPDATE [dbo].[trtBaseReference] 
SET [strDefault]=N'GG Director (Human)' WHERE [idfsBaseReference] = -528

UPDATE [dbo].[trtBaseReference] 
SET [strDefault]=N'GG Sentinel Surveillance Specialist' WHERE [idfsBaseReference] = -527

UPDATE [dbo].[trtBaseReference] 
SET [intRowStatus]=1 WHERE [idfsBaseReference] = -515

UPDATE [dbo].[trtBaseReference] 
SET [strDefault]=N'GG Administrator (Vet)', [intRowStatus]=1 WHERE [idfsBaseReference] = -514

UPDATE [dbo].[trtBaseReference] 
SET [strDefault]=N'GG Administrator (Human)' WHERE [idfsBaseReference] = -513

UPDATE [dbo].[trtBaseReference] 
SET [intHACode]=226, [intOrder]=0 WHERE [idfsBaseReference] = -506 

