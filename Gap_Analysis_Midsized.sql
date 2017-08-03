select unix_timestamp(beginlogdate) mss_begin
, unix_timestamp(endlogdate) mss_end
, serverkey
, machinekey
, paytableseries
, cashplayed
, cashin
, ticketin
, betsecs/gameplayed bet_freq
, cashplayed/gameplayed avg_bet
from dz.microsessionsummary mss
join dz.paytable pt on pt.paytablekey = mss.paytablekey
where serverid in (22, 521, 420, 419, 319, 306, 714, 483, 541, 501, 84, 63, 99, 375, 385, 161, 108, 128, 553, 141, 14, 111, 543, 556, 794, 548, 167, 107, 368, 546, 184, 302, 71, 273, 743, 829, 373, 275, 637, 702, 376, 713, 950, 175)
and businessdate_year_partition = 2016
and betsecs != 0
order by serverid, machinekey, mss_begin
;
