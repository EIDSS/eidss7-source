/*

	Mike Kornegay (from Mark Wilson)
	2/1/2023
	Reactivate user groups

*/

UPDATE dbo.trtBaseReference SET intRowStatus = 0  WHERE idfsReferenceType = 19000022 AND idfsBaseReference BETWEEN -529 AND -513