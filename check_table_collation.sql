/*** 重複度合い、整数の場合は実際のカーディナリー, 負の場合はテーブル内の行数に対する負の乗数。平均して2回は、-0.5となりPK、UKの場合は-1になる ***/

select starelid "テーブルOID",staattnum "列番号",stainherit "継承表の有無",stawidth "平均列長",stadistinct "重複度合いUKは-1" from pg_statistic limit 1 OFFSET 0;
