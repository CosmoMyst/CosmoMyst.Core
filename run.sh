sh ./build.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

BOLD=$(tput bold)
NW=$(tput sgr0)

printf "\nRunning..\n\n"

dub run --arch=x86_64 --compiler=ldc2

rc=$?;

printf "\n"
now=$(date +"%c")

if [ $rc != 0 ]
then
    printf "Run ${RED}${BOLD}failed${NW}${NC} in ${SECONDS} seconds at $now"
else 
    printf "Run was ${GREEN}${BOLD}successful${NW}${NC} in ${SECONDS} seconds at $now"
fi

printf "\n"