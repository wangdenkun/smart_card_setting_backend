scriptDir="$(dirname "$0")"
cd "$scriptDir" || exit
cd ../lib || exit
echo "Good"
fvm dart run main.dart