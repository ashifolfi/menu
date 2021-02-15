if [[ "$*" == *"release"* ]]; then
	PK3_RELEASE=1
fi

PK3_FLAGS=${PK3_FLAGS:-'L'}
PK3_VERSION=${PK3_VERSION:-'v0.0.0'}
PK3_NAME=${PK3_NAME:-'menu'}

PK3_FULLNAME="$PK3_FLAGS"_"$PK3_NAME"-"$PK3_VERSION"

if [[ ! $PK3_RELEASE ]]; then
	PK3_COMMIT=$(git rev-parse --short HEAD)
	PK3_TIME=$(date +"%m.%d.%y-%T")

	PK3_METADATA="$PK3_COMMIT"_"$PK3_TIME"

	PK3_FULLNAME="$PK3_FULLNAME"+"$PK3_METADATA"
fi

PK3_FILES=${PK3_FILES:-$(cat <<-END
	init.lua
	README.txt
	Lua/*
END
)}

cd $PK3_NAME
#rm ../builds/$PK3_FULLNAME.pk3
zip -FSr ../builds/$PK3_FULLNAME.pk3 $(echo $PK3_FILES | tr '\r\n' ' ')

cd ..
ln -sf builds/$PK3_FULLNAME.pk3 $PK3_NAME.pk3