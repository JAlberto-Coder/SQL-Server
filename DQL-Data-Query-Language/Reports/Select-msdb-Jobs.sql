USE msdb
GO
-- ========================================
-- Version:		1.0.0
-- Archivo:		Select-msdb-Jobs.sql
-- ========================================
-- Autor:		JAlberto-Coder
-- Fecha:		15-02-2021
-- Descripcion: Consultas para listar los JOBs que se tienen en el servidor
-- ========================================
-- CONSULTA GENERAL DE CADA JOB, consulta generada tomando como base la consulta realizada por Gustavo Herrera
-- ========================================
SELECT @@ServerName AS server_name
	, SJ.name AS job_name
	, SJ.description AS [description]
	, LEFT(SS.name,25) AS schedule_name
	, CASE(SS.freq_type)
		WHEN 1 THEN 'Once'
		WHEN 4 THEN 'Daily'
		WHEN 8 THEN (IIF(SS.freq_recurrence_factor > 1, CONCAT('Every ', CONVERT(VARCHAR(3), SS.freq_recurrence_factor), ' Weeks'), 'Weekly'))
		WHEN 16 THEN (IIF(SS.freq_recurrence_factor > 1, CONCAT('Every ', CONVERT(VARCHAR(3), SS.freq_recurrence_factor), ' Months'), 'Monthly'))
		WHEN 32 THEN CONCAT('Every ', CONVERT(VARCHAR(3), SS.freq_recurrence_factor), ' Months')
		WHEN 64 THEN 'SQL Startup'
		WHEN 128 THEN 'SQL Idle'
		ELSE '??'
	  END AS frequency
	, CASE
		WHEN (freq_type = 1) THEN 'One time only'
		WHEN (freq_type = 4 AND freq_interval = 1) THEN 'Every Day'
		WHEN (freq_type = 4 AND freq_interval > 1) THEN CONCAT('Every ', CONVERT(VARCHAR(10),freq_interval), ' Days')
		WHEN (freq_type = 8) THEN 
		(
			SELECT CONCAT(D1, D2, D3, D4, D5, D6, D7) AS [Weekly Schedule]
			FROM 
			(
				SELECT SS.schedule_id
					, freq_interval AS Interval
					, IIF(freq_interval & 1 <> 0, 'Sun', '') AS D1
					, IIF(freq_interval & 2 <> 0, 'Mon', '') AS D2
					, IIF(freq_interval & 4 <> 0, 'Tue ', '') AS D3
					, IIF(freq_interval & 8 <> 0, 'Wed ', '') AS D4
					, IIF(freq_interval & 16 <> 0, 'Thu ', '') AS D5
					, IIF(freq_interval & 32 <> 0, 'Fri ', '') AS D6
					, IIF(freq_interval & 64 <> 0, 'Sat ', '') AS D7
				FROM dbo.sysschedules SS
				WHERE freq_type = 8
			) AS F
			WHERE schedule_id = SJS.schedule_id
		)
		WHEN (freq_type = 16) THEN CONCAT('Day ', CONVERT(VARCHAR(2), freq_interval))
		WHEN (freq_type = 32) THEN 
		(
			SELECT freq_rel + WDAY
			FROM 
			(
				SELECT SS.schedule_id
				, CASE(freq_relative_interval)
					WHEN 1 THEN 'First'
					WHEN 2 THEN 'Second'
					WHEN 4 THEN 'Third'
					WHEN 8 THEN 'Fourth'
					WHEN 16 THEN 'Last'
					ELSE '??'
				  END AS freq_rel
				, CASE(freq_interval)
					WHEN 1 THEN ' Sun'
					WHEN 2 THEN ' Mon'
					WHEN 3 THEN ' Tue'
					WHEN 4 THEN ' Wed'
					WHEN 5 THEN ' Thu'
					WHEN 6 THEN ' Fri'
					WHEN 7 THEN ' Sat'
					WHEN 8 THEN ' Day'
					WHEN 9 THEN ' Weekday'
					WHEN 10 THEN ' Weekend'
					ELSE '??'
				  END AS WDAY
			FROM dbo.sysschedules SS
			WHERE SS.freq_type = 32
		) AS WS
		WHERE WS.schedule_id = SS.schedule_id
	 )
	 END AS Ocurrency
	, CASE(freq_subday_type)
		WHEN 1 THEN LEFT(STUFF((STUFF((REPLICATE('0', 6 - LEN(Active_Start_Time))) + CONVERT(VARCHAR(6),Active_Start_Time), 3, 0, ':')), 6, 0, ':'), 8)
		WHEN 2 THEN CONCAT('Every ', CONVERT(VARCHAR(10),freq_subday_interval), ' seconds')
		WHEN 4 THEN CONCAT('Every ', CONVERT(VARCHAR(10),freq_subday_interval), ' minutes')
		WHEN 8 THEN CONCAT('Every ', CONVERT(VARCHAR(10),freq_subday_interval), ' hours')
		ELSE '??'
	  END AS [time]
	, IIF(SJS.next_run_date = 0, CAST('n/a' AS CHAR(10)), CONVERT(CHAR(10), CONVERT(DATETIME, CONVERT(CHAR(8), SJS.next_run_date)), 120) + ' ' + LEFT(STUFF((STUFF((REPLICATE('0', 6 - LEN(next_run_time))) + CONVERT(VARCHAR(6), next_run_time), 3, 0, ':')), 6, 0, ':'), 8)) AS [Next Run Time]
	, CASE(SJ.enabled)
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE '??'
	  END AS [enable]
FROM dbo.sysjobschedules SJS
INNER JOIN dbo.sysjobs SJ ON SJ.job_id = SJS.job_id
INNER JOIN dbo.sysschedules SS ON SS.schedule_id = SJS.schedule_id
WHERE SJ.name <> 'syspolicy_purge_history'
ORDER BY SJ.name;
GO
-- ========================================
-- CONSULTA A DETALLE DE CADA JOB
-- ========================================
SELECT @@ServerName AS server_name
	, SJS.step_id AS step
	, SJS.step_name AS step_name
	, SJ.name AS job_name
	, SJS.subsystem AS [type]
	, SJS.command AS command
	, SJS.database_name AS [database_name]
	, SJS.last_run_duration AS last_run_duration
FROM dbo.sysjobs SJ
INNER JOIN dbo.sysjobsteps SJS ON SJ.job_id = SJS.job_id
WHERE SJ.name <> 'syspolicy_purge_history'
	AND SJ.enabled = 1
ORDER BY SJ.name, SJS.step_id;
GO