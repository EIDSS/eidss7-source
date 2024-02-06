/*
	Mark Wilson
	12/22/2022
	Update ffParameters for total and summing fields.

*/

update ffParameter
set idfsEditor = 10067011
where idfsParameter in (
9888030000000,
9888070000000,
9888230000000,
9888110000000,
9888150000000,
9888190000000,
9888270000000
) 

update ffParameter
set idfsEditor = 10067010
where idfsParameter = 9959830000000