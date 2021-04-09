
rm cm.log
rm -rf csrc
rm simv
rm -rf simv.daidir
rm -rf simv.vdb
rm ucli.key
rm -rf urgReport
rm vcs.log
rm -rf DVEfiles
rm -rf vcdplus.vpd
:<<'COMMENT'
echo "vcs"
vcs -f list \
-lca \
-cm line+cond+fsm+tgl+assert+path \
-debug_all \
-sverilog

echo "simv"
./simv \
-cm line+cond+fsm+tgl+assert+path

echo "urg"
urg -lca -dir simv.vdb
COMMENT
