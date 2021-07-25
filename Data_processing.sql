select COUNT(*) FROM AlphaOri..AIS_Data1
select count(*) from AlphaOri..AIS_Data

--Time stamp addition
update AlphaOri..AIS_Data
set TIME_GMT=CONVERT(datetime,LEFT(LTRIM(RTRIM([TIME])),LEN(LTRIM(RTRIM([TIME])))-3))

--3 kms logic
update AlphaOri..AIS_Data
set [3_kms_flag]=1
where 6371 * acos( cos( radians(1.2593655) )  
      * cos( radians( latitude ) ) 
      * cos( radians( Longitude ) - radians(103.75445) ) + sin( radians(1.2593655) ) 
      * sin(radians(latitude)) ) < 3

select top 1 * from AlphaOri..AIS_Data

select * from AlphaOri..AIS_Data where TIME_GMT between '2020-01-01 0:00:00.000' AND '2020-01-02 0:00:00.000' --and mmsi='232003233' order by TIME_GMT

--4 hour logic test
select * from AlphaOri..AIS_Data where [4_kms_flag]=1 order by mmsi,time_gmt 

--harvesine test
Drop table if exists #temp
SELECT *,
6371.0088 * acos( cos( radians(1.2593655) )  
      * cos( radians( latitude ) ) 
      * cos( radians( Longitude ) - radians(103.75445) ) + sin( radians(1.2593655) ) 
      * sin(radians(latitude)) ) AS distance_in_km 
into #temp
FROM AlphaOri..AIS_Data 
Where 6371.0088 * acos( cos( radians(1.2593655) )  
      * cos( radians( latitude ) ) 
      * cos( radians( Longitude ) - radians(103.75445) ) + sin( radians(1.2593655) ) 
      * sin(radians(latitude)) ) < 3 and TIME_GMT between '2020-01-01 0:00:00.000' AND '2020-01-02 0:00:00.000'


select max(latitude) as max_lat,max(longitude) as max_long,min(latitude) as min_lat,min(longitude) as min_long from #temp
select count(*) from #temp
select * from #temp order by distance_in_km desc