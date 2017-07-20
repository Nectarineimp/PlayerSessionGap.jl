rm nohup.out
nohup impala-shell -i vgthadoopdn1 -B --output_delimiter=',' -k --print_header -o Gap_Analysis.csv -f Gap_Analysis.sql &
