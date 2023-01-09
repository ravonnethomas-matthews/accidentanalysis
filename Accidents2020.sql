/*use uk_accidents_2022 */
/* insert copyright and license here dfdfb data set from the UK verified accident reports 2020 

check time bio of driver, driving conditions and vheicle
*/


					/* cleaning and loading to accident_details_2020 table */
--checking for duplicates
select accident_reference,
	count (accident_reference) 
from 
	st_Accident_Details_2020  
group by 
	accident_reference 
having
	count(accident_reference)>1
	
--cleaning & transformation
select ad.accident_reference, 
	ad.location_easting_osgr, 
	ad.location_northing_osgr, 
	cast (ad.accident_severity as int) as accident_severity_id, 
	case	
		when accident_severity=3 then 'slight'
		when accident_severity=2 then 'serious'
		when accident_severity=1 then 'fatal'
	end as accident_severity_desc, 
	cast (number_of_casualties as int) as number_of_casualties,
	ad.date as accident_date,
	year (convert (date, ad.date,103))as accident_year,
	month (convert (date, ad.date,103))as accident_month,
	DATENAME (MONTH,( convert (date, ad.date,103)))as accident_month_desc,
	day (convert (date, ad.date,103))as accident_day,
	DATENAME (WEEKDAY,( convert (date, ad.date,103)))as accident_day_desc,
	ad.time as accident_time,
	case
		when cast (ad.time as time) >= '0:00' and cast (ad.time as time) <= '2:59'   then '0:00-2:59'
		when cast (ad.time as time) >= '3:00' and cast (ad.time as time) <= '5:59'   then '3:00-5:59'
		when cast (ad.time as time) >= '6:00' and cast (ad.time as time) <= '8:59'   then '6:00-8:59'
		when cast (ad.time as time) >= '9:00' and cast (ad.time as time) <= '11:59'  then '9:00-11:59'
		when cast (ad.time as time) >= '12:00' and cast (ad.time as time) <= '14:59' then '12:00-14:59'
		when cast (ad.time as time) >= '15:00' and cast (ad.time as time) <= '17:59' then '15:00-17:59'
		when cast (ad.time as time) >= '18:00' and cast (ad.time as time) <= '20:59' then '18:00-20:59'
		when cast (ad.time as time) >= '21:00' and cast (ad.time as time) <= '23:59' then '21:00-23:59'
		else 'time not put in band'
	end as accident_time_band,
	cast (ad.road_type as int) as road_type,
	case
		when ad.road_type=1 then 'Roundabout'
		when ad.road_type=2 then 'One way street'
		when ad.road_type=3 then 'Dual carriageway'
		when ad.road_type=6 then 'Single carriageway'
		when ad.road_type=7 then 'Slip road'
		when ad.road_type=12 then 'One way street/Slip road'
		else 'road type not found'
	end as road_type_desc,
	cast (ad.speed_limit as int) as speed_limit,
	cast (ad.pedestrian_crossing_human_control as int) as pedestrian_crossing_human_control,
	case	
		when ad.pedestrian_crossing_human_control=0 then'None within 50 metres'
		when ad.pedestrian_crossing_human_control=1 then'Control by school crossing patrol'
		when ad.pedestrian_crossing_human_control=2 then'Control by other authorised person'
		else 'human control not found'
	end as pedestrian_crossing_human_control_desc,
	cast (ad.pedestrian_crossing_physical_facilities as int) as pedestrian_crossing_physical_facilities,
	case
		when ad.pedestrian_crossing_physical_facilities=0 then'No physical crossing facilities within 50 metres'
		when ad.pedestrian_crossing_physical_facilities=1 then'Zebra'
		when ad.pedestrian_crossing_physical_facilities=4 then'Pelican, puffin, toucan or similar non-junction pedestrian light crossing'
		when ad.pedestrian_crossing_physical_facilities=5 then'Pedestrian phase at traffic signal junction'
		when ad.pedestrian_crossing_physical_facilities=7 then'Footbridge or subway'
		when ad.pedestrian_crossing_physical_facilities=8 then'Central refuge'
		else 'Physical Facilities not found'
	end as pedestrian_crossing_physical_facilities_desc,
	cast (ad.light_conditions as int) as light_conditions,
	case	
		when light_conditions=1 then 'Daylight'
		when light_conditions=4 then 'Darkness - lights lit'
		when light_conditions=5 then 'Darkness - lights unlit'
		when light_conditions=6 then 'Darkness - no lighting'
		when light_conditions=7 then 'Darkness - lighting unknown'
	else 'light condition not found'
	end as light_conditions_desc,
	cast (ad.weather_conditions as int) as weather_conditions,
	case	
		when weather_conditions=1 then 'Fine no high winds'
		when weather_conditions=2 then 'Raining no high winds'
		when weather_conditions=3 then 'Snowing no high winds'
		when weather_conditions=4 then 'Fine + high winds'
		when weather_conditions=5 then 'Raining + high winds'
		when weather_conditions=6 then 'Snowing + high winds'
		when weather_conditions=7 then 'Fog or mist'
		when weather_conditions=8 then 'Fog or mist'
	else 'weather condition not found'
	end as weather_conditions_desc,
	cast (ad.road_surface_conditions as int) as road_surface_conditions,
	case	
		when road_surface_conditions=1 then 'Dry'
		when road_surface_conditions=2 then 'Wet or damp'
		when road_surface_conditions=3 then 'Snow'
		when road_surface_conditions=4 then 'Frost or ice'
		when road_surface_conditions=5 then 'Flood over 3cm. deep'
		when road_surface_conditions=6 then 'Oil or diesel'
		when road_surface_conditions=7 then 'Mud'
		else 'road surface conditions not found'
	end as road_surface_conditions_desc
into 
	Accident_Details_2020
from
	st_Accident_Details_2020 ad
where 
	ad.road_type not in ('9','-1') and 
	ad.speed_limit not in ('-1','99') and
	ad.pedestrian_crossing_human_control not in ('-1','9') and
	ad.pedestrian_crossing_physical_facilities not in ('-1', '9') and
	ad.light_conditions != '-1' and 
	ad.weather_conditions not in ('9', '-1') and
	ad.road_surface_conditions not in ('-1','9') 


							/* cleaning and loading to casualty table */

--checking for duplicates
select accident_reference,
	accident_reference+vehicle_reference+casualty_reference as 'Accident+Vehicle+Casualty_Reference', 
	count (accident_reference+vehicle_reference+casualty_reference) as 'Count'
from 
	st_Casualty_Details_2020
group by
	accident_reference, 
	accident_reference+vehicle_reference+casualty_reference
having
	count (accident_reference+vehicle_reference+casualty_reference)>1

--cleaning & transformation
select cd.accident_reference,
	cd.vehicle_reference,
	cd.casualty_reference, 
	cast (cd.casualty_class as int) as casualty_class,
	case
		when casualty_class=1 then 'Driver or rider'
		when casualty_class=2 then 'Passenger'
		when casualty_class=3 then 'Pedestrian'
		else 'casualty class not found'
	end as casualty_class_desc,
	cast (cd.sex_of_casualty as int) as sex_of_casuality,
	case 
		when sex_of_casualty=1 then 'Male'
		when sex_of_casualty=2 then 'Female'
		when sex_of_casualty=9 then 'unknown'
		else 'sex of casualty not found'
	end as sex_of_casualty_desc,
	cast (cd.age_of_casualty as int) as age_of_casualty,
	cast (cd.age_band_of_casualty as int) as age_band_of_casualty,
	case 
		when age_band_of_casualty=1 then '0-5'
		when age_band_of_casualty=2 then '6-10'
		when age_band_of_casualty=3 then '11-15'
		when age_band_of_casualty=4 then '16-20'
		when age_band_of_casualty=5 then '21-25'
		when age_band_of_casualty=6 then '26-35'
		when age_band_of_casualty=7 then '36-45'
		when age_band_of_casualty=8 then '46-55'
		when age_band_of_casualty=9 then '56-65'
		when age_band_of_casualty=10 then '66-75'
		when age_band_of_casualty=11 then 'Over 75'
		else 'age band not found'
	end as age_band_of_casualty_desc,
	cast (cd.casualty_severity as int) as casualty_severity,
	case 
		when casualty_severity=1 then 'Fatal'
		when casualty_severity=2 then 'Serious'
		when casualty_severity=3 then 'Slight'
		else 'severity not found'
	end as casuualty_severity_desc
into
Casualty_Details_2020
from
st_Casualty_Details_2020 as cd
where
cd.sex_of_casualty  !='-1' and 
cd.age_of_casualty != '-1' and	
cd.age_band_of_casualty != '-1' and
cd.age_of_casualty !='-1' and
cd.casualty_type !='99' 

	/* cleaning and loading to vehicle_details_2020 table */
--checking for duplicates
select accident_reference,
	accident_reference+vehicle_reference as 'Accident+Vehicle_Reference', 
	count (accident_reference+vehicle_reference) as 'Count'
from 
	Vehicle_Details_2020
group by
	accident_reference, 
	accident_reference+vehicle_reference
having
	count (accident_reference+vehicle_reference)>1

--checking for vehicle types actually in table
 select vehicle_type, count (vehicle_type) from Vehicle_Details_2020 group by vehicle_type order by 1
  --transforming and loading vehicles table
select vd.accident_reference,
	vd.accident_year,
	vd.vehicle_reference,
	cast (vd.vehicle_type as int) as vehicle_type,
	case 
		when vehicle_type=2 then 'Motorcycle 50cc and under'
		when vehicle_type=3 then 'Motorcycle 125cc and under'
		when vehicle_type=4 then 'Motorcycle over 125cc and up to 500cc'
		when vehicle_type=5 then 'Motorcycle over 500cc'
		when vehicle_type=8 then 'Taxi/Private hire car'
		when vehicle_type=9 then 'Car'
		when vehicle_type=10 then 'Minibus (8 - 16 passenger seats)'
		when vehicle_type=11 then 'Bus or coach (17 or more pass seats)'
		when vehicle_type=17 then 'Agricultural vehicle'
		when vehicle_type=19 then 'Van / Goods 3.5 tonnes mgw or under'
		when vehicle_type=20 then 'Goods over 3.5t. and under 7.5t'
		when vehicle_type=21 then 'Goods 7.5 tonnes mgw and over'
		when vehicle_type=90 then 'Other vehicle'
		when vehicle_type=98 then 'Goods vehicle - unknown weight'
		else 'vehicle type not found'
	end as vehicle_type_desc,
	case 
		when vehicle_type=2 then 'Motorcycle'
		when vehicle_type=3 then 'Motorcycle'
		when vehicle_type=4 then 'Motorcycle'
		when vehicle_type=5 then 'Motorcycle'
		when vehicle_type=8 then 'Taxi/Private hire car'
		when vehicle_type=9 then 'Private Car'
		when vehicle_type=10 then 'Bus 8+'
		when vehicle_type=11 then 'Bus 8+'
		when vehicle_type=17 then 'Agricultural vehicle'
		when vehicle_type=19 then 'Goods vehicle'
		when vehicle_type=20 then 'Goods vehicle'
		when vehicle_type=21 then 'Goods vehicle'
		when vehicle_type=90 then 'Other vehicle'
		when vehicle_type=98 then 'Goods vehicle'
		else 'vehicle category not found'
	end as vehicle_category,
	cast (vd.vehicle_left_hand_drive as int) as is_left_hand,
	case 
		when vehicle_left_hand_drive=1 then 'No'
		when vehicle_left_hand_drive=2 then 'Yes'
		else 'drive side not found'
	end as vehicle_left_hand_drive_desc,
	cast (vd.sex_of_driver as int) as sex_of_driver,
	case 
		when sex_of_driver=1 then 'Male'
		when sex_of_driver=2 then 'Female'
		when sex_of_driver=3 then 'unknown'
		else 'sex of driver not found'
	end as sex_of_driver_desc,
	cast (vd.age_of_driver as int) as age_of_driver,
	cast (vd.age_band_of_driver as int) as age_band_of_driver,
	case 
		when age_band_of_driver=1 then '0-5'
		when age_band_of_driver=2 then '6-10'
		when age_band_of_driver=3 then '11-15'
		when age_band_of_driver=4 then '16-20'
		when age_band_of_driver=5 then '21-25'
		when age_band_of_driver=6 then '26-35'
		when age_band_of_driver=7 then '36-45'
		when age_band_of_driver=8 then '46-55'
		when age_band_of_driver=9 then '56-65'
		when age_band_of_driver=10 then '66-75'
		when age_band_of_driver=11 then 'Over 75'
		else 'age band not found'
	end as age_band_of_driver_desc,
	cast (vd.engine_capacity_cc as int) as engine_capacity_cc,
	case 
		when engine_capacity_cc >0 and engine_capacity_cc <=500 then '0-500'
		when engine_capacity_cc >500 and engine_capacity_cc <=1000 then '501-1000'
		when engine_capacity_cc >1000 and engine_capacity_cc <=1500 then '1001-1500'
		when engine_capacity_cc >1500 and engine_capacity_cc <=2000 then '1501-2000'
		when engine_capacity_cc >2000 and engine_capacity_cc <=2500 then '2001-2500'
		when engine_capacity_cc >2500 and engine_capacity_cc <=3000 then '2501-3000'
		when engine_capacity_cc >3000 and engine_capacity_cc <=3500 then '3001-3500'
		when engine_capacity_cc >3500 and engine_capacity_cc <=4000 then '3501-4000'
		when engine_capacity_cc >4000  then '4000+'
		else 'engine cc band out of range'
	end as engine_cc_band,
	cast (vd.age_of_vehicle as int) as age_of_vehicle,
	case  
		when age_of_vehicle <=2 then 'new-2'
		when age_of_vehicle >2 and age_of_vehicle <=5 then '3-5'
		when age_of_vehicle >5 and age_of_vehicle <=8 then '5-8'
		when age_of_vehicle >8 and age_of_vehicle <=12 then '9-12'
		when age_of_vehicle >12 then '13+'
		else 'vehicle age out of range'
	end as age_of_vehicle_band,
	vd.generic_make_model,
	SUBSTRING(generic_make_model, 1, CHARINDEX(' ', generic_make_model +' ')-1) as vehicle_make, vc.country
into
	Vehicle_Details_2020
from
	st_Vehicle_Details_2020 vd
inner join
	vehicle_make_country vc
on
	vc.make= (SUBSTRING(generic_make_model, 1, CHARINDEX(' ', generic_make_model +' ')-1))
where 
	vd.vehicle_type != '-1' and 
	vd.vehicle_left_hand_drive not in ('-1','9') and
	vd.vehicle_type not in ( '-3','-1') and
	vd.age_of_driver != '-1' and
	vd.age_band_of_driver != '-1' and
	vd.engine_capacity_cc != '-1' and
	vd.age_of_vehicle!='-1' and
	vd.propulsion_code != '-1' and
	vd.generic_make_model != '-1' 
	

	select * from Vehicle_Details_2020
	select * from Casualty_Details_2020
	select * from Accident_Details_2020

								/*checking impact of date time on accidents*/ 

--day of week
select accident_severity as Severity_ID, 
	case	
		when accident_severity=3 then 'slight'
		when accident_severity=2 then 'serious'
		when accident_severity=1 then 'fatal'
	end as Severity, 
	day_of_week,
	count(accident_severity) number_of_accidents
from 
	Accident_Details_2020 
group by 
	accident_severity , Day_of_Week
order by accident_severity desc, number_of_accidents desc

--month of year
select accident_severity_id as Severity_ID, 
	case	
		when accident_severity_id=3 then 'slight'
		when accident_severity_id=2 then 'serious'
		when accident_severity_id=1 then 'fatal'
	end as Severity,
	DATENAME (MONTH,( convert (date, accident_date,103)))as Month_Of_Year
	--count(accident_severity_id) number_of_accidents
from 
	Accident_Details_2020v2
group by 
	accident_severity_id ,month( convert (date, accident_date,103))
order by 
accident_severity_id desc, month( convert (date, accident_date,103))

select * from Accident_Details_2020v2

---time of day
with tme as(
select accident_severity as Severity_ID, 
	case	
		when accident_severity=3 then 'slight'
		when accident_severity=2 then 'serious'
		when accident_severity=1 then 'fatal'
	end as Severity,
	accident_time as Time_Of_Day,
	case
		when cast (accident_time as time) >= '0:00' and cast (accident_time as time) <= '2:59'   then '0:00-2:59'
		when cast (accident_time as time) >= '3:00' and cast (accident_time as time) <= '5:59'   then '3:00-5:59'
		when cast (accident_time as time) >= '6:00' and cast (accident_time as time) <= '8:59'   then '6:00-8:59'
		when cast (accident_time as time) >= '9:00' and cast (accident_time as time) <= '11:59'  then '9:00-11:59'
		when cast (accident_time as time) >= '12:00' and cast (accident_time as time) <= '14:59' then '12:00-14:59'
		when cast (accident_time as time) >= '15:00' and cast (accident_time as time) <= '17:59' then '15:00-17:59'
		when cast (accident_time as time) >= '18:00' and cast (accident_time as time) <= '20:59' then '18:00-20:59'
		when cast (accident_time as time) >= '21:00' and cast (accident_time as time) <= '23:59' then '21:00-23:59'
		else accident_time
	end as accident_time_band,
		count(accident_severity) number_of_accidents
from 
	Accident_Details_2020
group by 
	accident_severity,  accident_time,
	case
		when cast (accident_time as time) >= '0:00' and cast (accident_time as time) <= '2:59'   then '0:00-2:59'
		when cast (accident_time as time) >= '3:00' and cast (accident_time as time) <= '5:59'   then '3:00-5:59'
		when cast (accident_time as time) >= '6:00' and cast (accident_time as time) <= '8:59'   then '6:00-8:59'
		when cast (accident_time as time) >= '9:00' and cast (accident_time as time) <= '11:59'  then '9:00-11:59'
		when cast (accident_time as time) >= '12:00' and cast (accident_time as time) <= '14:59' then '12:00-14:59'
		when cast (accident_time as time) >= '15:00' and cast (accident_time as time) <= '17:59' then '15:00-17:59'
		when cast (accident_time as time) >= '18:00' and cast (accident_time as time) <= '20:59' then '18:00-20:59'
		when cast (accident_time as time) >= '21:00' and cast (accident_time as time) <= '23:59' then '21:00-23:59'
		else accident_time
	end 
)
select accident_time_band, count (number_of_accidents) accident_count
from tme group by accident_time_band order by accident_count

								/*checking impact of driving conditions on accidents*/ 
--road type
select road_type, 
	count (accident_reference) as number_of_accidents
from
	Accident_Details_2020
group by
	road_type 
order by 
	number_of_accidents

select accident_severity as Severity_ID, 
	case	
		when accident_severity=3 then 'slight'
		when accident_severity=2 then 'serious'
		when accident_severity=1 then 'fatal'
	end as Severity, 
	road_type, 
	count (accident_reference) as number_of_accidents
from 
	accident_details_2020
group by 
	accident_severity ,road_type
order by Severity_ID ,number_of_accidents

--lighting conditions
select light_conditions, 
	count (accident_reference) as number_of_accidents
from
	Accident_Details_2020
group by
	light_conditions 
order by 
	number_of_accidents

select accident_severity as Severity_ID, 
	case	
		when accident_severity=3 then 'slight'
		when accident_severity=2 then 'serious'
		when accident_severity=1 then 'fatal'
	end as Severity, 
	light_conditions, 
	count (accident_reference) as number_of_accidents
from 
	accident_details_2020
group by 
	accident_severity ,light_conditions
order by Severity_ID ,number_of_accidents

--road surface conditions
select road_surface_conditions, 
	count (accident_reference) as number_of_accidents
from
	Accident_Details_2020
group by
	road_surface_conditions 
order by 
	number_of_accidents

select accident_severity as Severity_ID, 
	case	
		when accident_severity=3 then 'slight'
		when accident_severity=2 then 'serious'
		when accident_severity=1 then 'fatal'
	end as Severity, 
	road_surface_conditions, 
	count (accident_reference) as number_of_accidents
from 
	accident_details_2020
group by 
	accident_severity ,road_surface_conditions
order by Severity_ID ,number_of_accidents


--weather conditions
select weather_conditions, 
	count (accident_reference) as number_of_accidents
from
	Accident_Details_2020
group by
	weather_conditions 
order by 
	number_of_accidents

select accident_severity as Severity_ID, 
	case	
		when accident_severity=3 then 'slight'
		when accident_severity=2 then 'serious'
		when accident_severity=1 then 'fatal'
	end as Severity, 
	weather_conditions, 
	count (accident_reference) as number_of_accidents
from 
	accident_details_2020
group by 
	accident_severity ,weather_conditions
order by Severity_ID ,number_of_accidents


--speed limit conditions
select speed_limit, 
	count (accident_reference) as number_of_accidents
from
	Accident_Details_2020
group by
	speed_limit 
order by 
	number_of_accidents

select accident_severity as Severity_ID, 
	case	
		when accident_severity=3 then 'slight'
		when accident_severity=2 then 'serious'
		when accident_severity=1 then 'fatal'
	end as Severity, 
	speed_limit, 
	count (accident_reference) as number_of_accidents
from 
	accident_details_2020
group by 
	accident_severity ,speed_limit
order by Severity_ID ,number_of_accidents


select * from Accident_Details_2020