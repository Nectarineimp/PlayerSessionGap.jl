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
where locationid_partition in (82, 280)
and businessdate_year_partition = 2016
and betsecs != 0
and denominationkey = 6
and paytableseries in ('M1', 'M4', 'M37WAP', 'M38WAP')
order by serverkey, machinekey, mss_begin
;
