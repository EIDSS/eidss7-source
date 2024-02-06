
-- ================================================================================================
-- Name: USP_OMM_Contact_GetDetail
--
-- Description: Insert/Update for Campaign Monitoring Session
--          
-- Author: Doug Albanese
--
-- Revision History:
-- Name           Date       Change Detail
-- -------------- ---------- ---------------------------------------------------------------------
-- Doug Albanese  02/23/2019 Created new SP for obtaining Contact Details
-- Stephen Long   12/26/2019 Replaced 'en' with @LangID on reference call.
-- Doug Albanese  06/15/2020	Add Phone number on return
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Contact_GetDetail] (
	@LangID NVARCHAR(50),
	@OutbreakCaseContactUID BIGINT
	)
AS
BEGIN
	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @Human BIT = 0;

	BEGIN TRY
		IF EXISTS (
				SELECT OutbreakCaseContactUID
				FROM dbo.OutbreakCaseContact
				WHERE ContactedHumanCasePersonID IS NOT NULL
					AND OutbreakCaseContactUID = @OutbreakCaseContactUID
				)
		BEGIN
			SET @Human = 1
		END

		IF @Human = 1
		BEGIN
			SELECT H.strLastName,
				H.strFirstName,
				H.strSecondName AS strMiddleName,
				H.datDateofBirth,
				HAAI.ReportedAge AS strAge,
				Citizenship.name AS strCitizenship,
				Gender.name AS strGender,
				geo.idfsCountry,
				geo.idfsRegion,
				geo.idfsRayon,
				geo.idfsSettlement,
				geo.strStreetName,
				geo.strPostCode,
				geo.strBuilding,
				geo.strHouse,
				geo.strApartment,
				geo.strAddressString,
				CONCAT(HAAI.ContactPhoneCountryCode, HAAI.ContactPhoneNbr) AS ContactPhoneNbr,
				Region.name AS Region,
				Rayon.name AS Rayon,
				Settlement.name AS Settlement,
				OCC.ContactRelationshipTypeID AS idfsPersonContactType,
				OCC.DateOfLastContact AS datDateOfLastContact,
				OCC.PlaceOfLastContact AS strPlaceInfo,
				OCC.CommentText AS strComments,
				OCC.ContactStatusID
			FROM dbo.OutbreakCaseContact OCC
			INNER JOIN dbo.tlbContactedCasePerson CCP
				ON CCP.idfContactedCasePerson = OCC.ContactedHumanCasePersonID
			INNER JOIN dbo.tlbHuman H
				ON H.idfHuman = CCP.idfHuman
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000043) Gender
				ON Gender.idfsReference = H.idfsHumanGender
			LEFT JOIN dbo.tlbGeoLocation geo
				ON H.idfCurrentResidenceAddress = geo.idfGeoLocation
			LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LangID, 19000002) Rayon
				ON Rayon.idfsReference = geo.idfsRayon
			LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LangID, 19000003) Region
				ON Region.idfsReference = geo.idfsRegion
			LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LangID, 19000004) Settlement
				ON Settlement.idfsReference = geo.idfsSettlement
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000054) Citizenship
				ON Citizenship.idfsReference = H.idfsNationality
			INNER JOIN dbo.HumanActualAddlInfo HAAI
				ON HAAI.HumanActualAddlInfoUID = H.idfHumanActual
			WHERE OCC.OUtbreakCaseContactUID = @OUtbreakCaseContactUID
		END
		ELSE
		BEGIN
			SELECT H.strLastName,
				H.strFirstName,
				H.strSecondName AS strMiddleName,
				H.datDateofBirth,
				HAAI.ReportedAge AS strAge,
				Citizenship.name AS strCitizenship,
				Gender.name AS strGender,
				geo.idfsCountry,
				geo.idfsRegion,
				geo.idfsRayon,
				geo.idfsSettlement,
				geo.strStreetName,
				geo.strPostCode,
				geo.strBuilding,
				geo.strHouse,
				geo.strApartment,
				geo.strAddressString,
				CONCAT(HAAI.ContactPhoneCountryCode, HAAI.ContactPhoneNbr) AS ContactPhoneNbr,
				Region.name AS Region,
				Rayon.name AS Rayon,
				Settlement.name AS Settlement,
				OCC.ContactRelationshipTypeID AS idfsPersonContactType,
				OCC.DateOfLastContact AS datDateOfLastContact,
				OCC.PlaceOfLastContact AS strPlaceInfo,
				OCC.CommentText AS strComments,
				OCC.ContactStatusID
			FROM dbo.OutbreakCaseContact OCC
			INNER JOIN dbo.tlbHuman H
				ON H.idfHuman = OCC.idfHuman
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000043) Gender
				ON Gender.idfsReference = H.idfsHumanGender
			LEFT JOIN dbo.tlbGeoLocation geo
				ON H.idfCurrentResidenceAddress = geo.idfGeoLocation
			LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LangID, 19000002) Rayon
				ON Rayon.idfsReference = geo.idfsRayon
			LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LangID, 19000003) Region
				ON Region.idfsReference = geo.idfsRegion
			LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LangID, 19000004) Settlement
				ON Settlement.idfsReference = geo.idfsSettlement
			LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000054) Citizenship
				ON Citizenship.idfsReference = H.idfsNationality
			INNER JOIN dbo.HumanActualAddlInfo HAAI
				ON HAAI.HumanActualAddlInfoUID = H.idfHumanActual
			WHERE OCC.OUtbreakCaseContactUID = @OUtbreakCaseContactUID
		END
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;

		THROW;
	END CATCH

	SELECT @returnCode AS ReturnCode,
		@returnMsg AS ReturnMsg
END
