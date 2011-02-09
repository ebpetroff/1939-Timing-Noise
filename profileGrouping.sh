#!/bin/bash

#for loopVar in 50 60 70 80 90 100 110 120
#do

loopVar=$1

#X=$1
X=$loopVar
n=1
echo $X
step=0

rm testF*
#rm *Shape1341
#rm *Shape1405
rm firstShape1341* secondShape1341*
rm firstShape1405* secondShape1405*
rm Postscripts/1341_* Postscripts/1405_*


counter=`head -n1 /u/pet22d/test | awk '{print $2}'`
lastObservation=`tail -n1 /u/pet22d/test | awk '{print $2}'`

echo $counter
echo $lastObservation

otherCounter=${counter/.*}
counterInt=${counter/.*}
fixedCounter=${counter/.*}
lastObservationInt=${lastObservation/.*}
#echo $counterInt $lastObservationInt

while [ $otherCounter -le $(($fixedCounter+$X)) ]
do

## groups profiles by $X days according to MJD
while [ $counterInt -lt $(($lastObservationInt+1)) ] 
	do
	echo $n $counterInt $(($counterInt+$X))
	for i in `awk '{print $2}' /u/pet22d/test`
		do
#		echo $i
		intI=${i/.*}
#		echo $intI
		if [[ $intI -le $(($counterInt+$X)) && $intI -gt $counterInt ]]
			then
		#	echo $intI
			grep $i /u/pet22d/test >> testFile_${n}
			#awk '{print $1}' /u/pet22d/test >> testFile_${n}
		fi
		if [[ $intI -le $counterInt ]]
			then
			grep $i /u/pet22d/test >> testFile_0
		fi
	done
	counterInt=$(($counterInt + $X))
	n=$(($n+1))

done
echo $n

## adds all the profiles in each bin together
#for (( x=1; x<=$(($n-1)); x++ ))
#	do
#	echo $x
#	psradd -E /u/hob044/emily/m2008.par -o m_${x}.czFt `grep m2* /u/pet22d/testFile_${x} | awk '{print "/pulsar/archive16/ppta_finalFiles//J1939+2134/20cm/" $1}'`
#done


loop=1
if [ $loop = 1 ]
	then

for (( y=1; y<=$(($n-1)); y+=2 ))
	do
	echo $y
	for i in `awk '{print $1}' /u/pet22d/testFile_${y}`
		do
		vap -c freq /pulsar/archive16/ppta_finalFiles//J1939+2134/20cm/$i > temp
		freq=`awk 'NR==2 {print $2}' /u/pet22d/temp`
		intFreq=${freq/.}
		if [[ $intFreq -lt 1400000 ]]
			then
			echo $i >> firstShape1341_${step}
		else
			echo $i >> firstShape1405_${step}
		fi
	done	
done

for (( z=0; z<=$(($n-1)); z+=2 ))
	do
	echo $z
	for i in `awk '{print $1}' /u/pet22d/testFile_${z}`
		do
		vap -c freq /pulsar/archive16/ppta_finalFiles//J1939+2134/20cm/$i > temp2
		freq2=`awk 'NR==2 {print $2}' /u/pet22d/temp2`
		intFreq2=${freq2/.}
		if [[ $intFreq2 -lt 1400000 ]]
			then
			echo $i >> secondShape1341_${step}
		else
			echo $i >> secondShape1405_${step}
		fi
	done	
done
fi

## adding the profiles into shape1 and shape2 then processing the combined profiles
psradd -o /u/pet22d/Profiles/firstShape1341_${step}.czFt `grep \.czFTp /u/pet22d/firstShape1341_${step} | awk '{print "/pulsar/archive16/ppta_finalFiles//J1939+2134/20cm/" $1}'`

psradd -o /u/pet22d/Profiles/firstShape1405_${step}.czFt `grep \.czFTp /u/pet22d/firstShape1405_${step} | awk '{print "/pulsar/archive16/ppta_finalFiles//J1939+2134/20cm/" $1}'`

psradd -o /u/pet22d/Profiles/secondShape1341_${step}.czFt `grep \.czFTp /u/pet22d/secondShape1341_${step} | awk '{print "/pulsar/archive16/ppta_finalFiles//J1939+2134/20cm/" $1}'`

psradd -o /u/pet22d/Profiles/secondShape1405_${step}.czFt `grep \.czFTp /u/pet22d/secondShape1405_${step} | awk '{print "/pulsar/archive16/ppta_finalFiles//J1939+2134/20cm/" $1}'`

pam -D -e czFtD /u/pet22d/Profiles/*_${step}.czFt
	
pam -T -e czFTD /u/pet22d/Profiles/*_${step}.czFtD

pat -s /u/pet22d/Profiles/firstShape1341_${step}.czFTD -t /u/pet22d/Profiles/*1341_${step}.czFTD -K /ps

cp pgplot.ps /u/pet22d/Postscripts/1341_${step}_compare.ps

pat -s ./Profiles/firstShape1405_${step}.czFTD -t ./Profiles/*1405_${step}.czFTD -K /ps

cp pgplot.ps ./Postscripts/1405_${step}_compare.ps

otherCounter=$(($otherCounter+10))
step=$(($step+10))

done #while $counter<$counter+$X

echo $step

#done #for 50 60 70 80 ...
