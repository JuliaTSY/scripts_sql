USE [MEDIALOG]
GO
/****** Object:  StoredProcedure [dbo].[pl_CheckNewPlanning]    Script Date: 12.04.2024 10:47:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[pl_CheckNewPlanning](@PLANNINGID int, @STATE int output, @MSG varchar(2048) output, @LANG varchar(10) = null, @TM_SERVICE_CODE varchar(10) = '', @MSG_INFO varchar(2048) output) AS    BEGIN
  declare @ISBUSY int, @ISRIGHTEXAM int;
  declare @ISBUSY_14 int
  declare @NEEDED_EXAM table(exam_id int)
  insert into @NEEDED_EXAM
  select pl_exam_id from pl_exam where pl_exam_id in (4,7,9,11,12,14,21,27,29,30	,31	,32	,33	,36	,38	,39	,40	,468	,470	,472	,474	,479	,481	,483	,485	,487	,489	,
491	,493	,495	,497	,499	,501	,503	,505	,561	,564	,569	,570	,
572	,574	,575	,576	,577	,579	,581	,583	,585	,589	,591	,592	,
593	,595	,597	,602	,604	,606	,608	,683	,684	,685	,841	,844	,
845	,847	,849	,851	,963	,1090	,1093	,1095	,1108	,1110	,1131	,1141	,
1142	,1143	,1148	,1150	,1155	,1160	,1165	,1170	,1172	,1174	,1175	,
1176	,1177	,1185	,1266	,1292	,1293	,1294	,1756	,4000008	,4000009	,
4000141	,4000147	,4000153	,4000247	,4000249	,4000250	,4000266	,4000285	,
4000290	,4000297	,4000306	,4000307	,4000308	,4000324	,4000325	,4000326	,
4000349	,4000370	,4000408	,4000411	,4000422	,4000424	,4000425	,4000451	,
4000467	,4000500	,4000512	,4000529	,4000532	,4000536	,4000542	,4001618	,
4001629	,4001634	,4001671	,4001683	,4001691	,4001708	,4001764	
)

  set @ISBUSY=0;
  set @ISBUSY_14=0;
  set @ISRIGHTEXAM=0;
  set @STATE=0;
  set @MSG='';
  
  select top 1 @ISBUSY=count(*) from planning where planning.DATE_CONS=(select top 1 p.date_cons from planning p where p.planning_id=@PLANNINGID) and 
  planning.status=0 and  planning.pl_exam_id in (select * from @NEEDED_EXAM)  
  and planning.patients_id=(select top 1 p.patients_id from planning p where p.planning_id=@PLANNINGID)

   select top 1 @ISBUSY_14=count(*) from planning where 
   planning.DATE_CONS between dateadd(dd,-7,(select top 1 p.date_cons from planning p where p.planning_id=@PLANNINGID))
   and dateadd(dd,7,(select top 1 p.date_cons from planning p where p.planning_id=@PLANNINGID))
    and 
  planning.status=0 and  planning.pl_exam_id in (select * from @NEEDED_EXAM)  
  and planning.patients_id=(select top 1 p.patients_id from planning p where p.planning_id=@PLANNINGID)

  select top 1 @ISRIGHTEXAM=count(*) from planning where planning.planning_id=@PLANNINGID 
and planning.pl_exam_id in (select * from @NEEDED_EXAM) ;

if @ISRIGHTEXAM=1
  if @ISBUSY>=3
	begin
		set @MSG='У пациента уже есть 3 действующих приема в этот день. Всё равно записать его?';
		set @STATE=1;
	end
if @ISRIGHTEXAM=1
	if (SELECT fc.fm_contr_id
		FROM FM_CLINK Fcl
		join fm_contr fc on fcl.FM_CONTR_ID=fc.FM_CONTR_ID
		WHERE Fcl.FM_CLINK_ID=(
			SELECT TOP 1 P.FM_CLINK_ID
			FROM FM_CLINK_PATIENTS P
			WHERE P.CANCEL=0 AND P.PATIENTS_ID=(select top 1 p.patients_id from planning p where p.planning_id=@PLANNINGID) AND convert(date, p.DATE_TO, 104)>=convert(date, getdate(), 104)
			ORDER BY P.DATE_CREATE DESC)
			 ) in (4018172,4018173,4018176)
		if @ISBUSY_14>=2
			begin
				set @MSG='У пациента уже есть 2 действующих приема в течение 14 дней. Всё равно записать его?'+ ' Действующий договор: '+
				(SELECT fc.CODE
					FROM FM_CLINK Fcl
					join fm_contr fc on fcl.FM_CONTR_ID=fc.FM_CONTR_ID
					WHERE Fcl.FM_CLINK_ID=(
					SELECT TOP 1 P.FM_CLINK_ID
					FROM FM_CLINK_PATIENTS P
					WHERE P.CANCEL=0 AND P.PATIENTS_ID=(select top 1 p.patients_id from planning p where p.planning_id=@PLANNINGID) AND convert(date, p.DATE_TO, 104)>=convert(date, getdate(), 104)
					ORDER BY P.DATE_CREATE DESC)
				 )
				set @STATE=1;
			end

		
END
