declare @devation int =5 --minutes

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

--## Take 11 Runid's 1 is today's run and another 10 runs are previous days##-----
if  object_id('tempdb..#runs') is not null
drop table #runs
select top 11 runid into #runs from ctrl.run where jobtypecd='DAILY' order by runid desc

--## Get currently running jobs info ##-----
if object_id('tempdb..#runpackages') is not null
  drop table #runpackages
select jobcd,jobpackagecd,datediff(minute,begindts,getdate()) duration_tillnow into #runpackages 
from ctrl.runpackage where runid in(select top 1 runid from #runs order by runid desc) and jobstatuscd='r'

--## Get previous 10 run's jobs info ##-----
--## avg_duration is average of last 10 run's duration##---
--## max_durartion is maximum duration of a job in last 10 run's##--- 

if object_id('tempdb..#previousrunsinfo') is not null
  drop table #previousrunsinfo
select jobcd,jobpackagecd,avg(datediff(minute,begindts,enddts)) avg_duration,max(datediff(minute,begindts,enddts)) max_durartion 
into #previousrunsinfo
from ctrl.runpackage where runid in(select top 10 runid from #runs order by runid asc) and jobstatuscd='c'
and jobpackagecd in (select jobpackagecd from #runpackages group by jobpackagecd)
group by jobcd,jobpackagecd

--## Generate HTML table formats--##
select a.Jobcd,b.Jobpackagecd ,a.Duration_tillnow  ,b.Max_durartion ,b.Avg_duration
from #runpackages a inner join #previousrunsinfo b
on a.jobcd=b.jobcd and a.jobpackagecd=b.jobpackagecd
--and a.duration_tillnow >b.max_durartion+@devation --and b.avg_duration>=15 --check only for 15 minutes longer duration jobs

 --Select  AgentName, AgentStatusCode, IsEnabled
               -- From Ctrl.Agent Where AgentCode = Zena_CA;


--UPDATE  Ctrl.Agent  set AgentStatusCode='I' where AgentName='Hadoop Agent'

--update ctrl.RunPackage set JobStatusCd='O' where RunId=3605 and JobStatusCd='A' 