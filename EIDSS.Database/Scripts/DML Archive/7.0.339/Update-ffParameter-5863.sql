/*
	Author: Doug Albnaese

	Must run this during migration!

	For any existing DB's, this mus also be run to get the "Editor Types" corrected.

	This was missed on the Summing / Total addition, as the 10067008 (Text Box) was left behind without any instruction on what to do.
*/

UPDATE
   ffParameter
SET
   idfsEditor = 10067009 --Up/Down Control
WHERE
   idfsEditor = 10067008 and idfsParameterType = 10071059 --Natural Number