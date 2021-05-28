select now(),  
case EXTRACT(DOW FROM CAST(now() AS DATE))
when 0 then '日'
when 1 then '月'
when 2 then '火'
when 3 then '水'
when 4 then '木' 
when 5 then '金' 
when 6 then '土'
end as d_of_week;
