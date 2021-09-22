psql app -c "COPY (select note,create_time \
from t_post where create_time >='2020-05-01') \
to '/tmp/sample.tsv' DELIMITER E'\\t';"
