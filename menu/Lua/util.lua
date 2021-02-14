local gmutil = {}

function gmutil.fixedLerp(a, b, v)
	return a + FixedMul(b - a, v)
end

-- lol
function table.last(readTable)
	return readTable[#readTable]
end

return gmutil