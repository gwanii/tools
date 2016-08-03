# update repository
for d in `ls`
do
    if [[ -d $d ]]; then
        cd $d
        git pull origin master
        cd ..
    fi
done

# who and when push the first commit
#for d in `ls`
#do
#    if [[ -d $d ]]; then
#        cd $d
#        echo $d: $(git log | tail -n 6 | grep -E "Date|Author")
#        cd ..
#    fi
#done
