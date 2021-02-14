PK3_FLAGS=${PK3_FLAGS:-'L'}
PK3_VERSION=${PK3_VERSION:-'v0.0.0'}
PK3_NAME=${PK3_NAME:-'menu'}

PK3_FULLNAME="$PK3_FLAGS"_"$PK3_NAME"-"$PK3_VERSION"

PK3_FILES=${PK3_FILES:-$(cat <<-END
	init.lua
	README.txt
	Lua/*
END
)}

cd $PK3_NAME
#rm ../$PK3_FULLNAME.pk3
zip -FSr ../$PK3_FULLNAME.pk3 $(echo $PK3_FILES | tr '\r\n' ' ')

cd ..
ln -sf $PK3_FULLNAME.pk3 $PK3_NAME.pk3