PRO llval2kml, filename=filename

st            =   read_llval(filename=filename)
out           =   write_llval2kml(st, filename=filename)

END