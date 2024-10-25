-- Update from Keith in order to fix GeoLocation issue
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location f_adr{0}  {1}{)}' where idfSearchTable = 4582610000000
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location gl_emp_hc{0}  {1}{)}' where idfSearchTable = 4582710000000
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location gl_hc{0}   {1}{)}' where idfSearchTable = 4582770000000
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location f_loc{0}   {1}{)}' where idfSearchTable = 4582630000000
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location gl_cr_hc{0}   {1}{)}' where idfSearchTable = 4582700000000
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location gl_reg_hc{0}   {1}{)}' where idfSearchTable = 4582780000000
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location gl_outb{0}   {1}{)}' where idfSearchTable = 4582910000000
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location gl_primary_hc{0}   {1}{)}' where idfSearchTable = 4583090000002
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location v_loc{0}   {1}{)}' where idfSearchTable = 4583090000011
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location gl_vss{0}   {1}{)}' where idfSearchTable = 4583090000014
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location vss_loc{0}   {1}{)}' where idfSearchTable = 4583090000016
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location glve_hc{0}   {1}{)}' where idfSearchTable = 4583090000058
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location vss_sum_gl{0}   {1}{)}' where idfSearchTable = 4583090000060
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location glcra_human_bss{0}   {1}{)}' where idfSearchTable = 4583090000069
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location as_floc{0}   {1}{)}' where idfSearchTable = 4583090000101

GO