SELECT extract(epoch from (cast(日付 as timestamp) - cast(日付 as timestamp)))/60  FROM テーブル where id = 差分(分);
