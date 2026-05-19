if [ "$#" = 2 ]; then
    cp $1 $2
else
    echo error >&2
    exit 2
fi
