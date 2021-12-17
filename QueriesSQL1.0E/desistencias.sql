select *
from sstatus
where DESCRICAO='Abandono'

select T.STATUS, T.STATUSRES, COUNT(T.CODSTATUSRES) AS 'TOTAL'
from(
	select SM.CODSTATUS, S1.DESCRICAO AS 'STATUS',
		SM.CODSTATUSRES, s2.DESCRICAO AS 'STATUSRES'
	from Smatricula SM
		inner join sstatus as S1 on sm.CODSTATUS=s1.CODSTATUS
		inner join sstatus as S2 on sm.CODSTATUSRES=s2.CODSTATUS
	where sm.CODSTATUS != sm.CODSTATUSRES
	) AS T
group by T.STATUS, T.STATUSRES
ORDER BY T.STATUS

