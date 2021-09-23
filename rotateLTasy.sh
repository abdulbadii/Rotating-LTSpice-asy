rotLTSym(){
local D=45 DR F PR
[[ $1 =~ ^(-d=)?(-?[0-9]+)$ ]] &&(($#>1))&&{	D=${BASH_REMATCH[2]}
	[ ${D:0:1} = - ]&&{ echo Degree \'$D\' cannot be negative;return;};shift;}
for i;{
	if [ -d "$i" ] ;then	fn=\*.asy
		if [ "$i" = . ] ;then F=1
		else DR="$DR"\ $i ;fi
	elif [ -f "$i" ] ;then	fn="$fn"\ ${i%.asy}.asy ;F=1
	elif [ "$i" ] ;then echo No regular file \'$i\' exists;return
	else echo For usage explanation, read on;return;fi;}
for DR in $F $DR ;{
((F)) ||{ cd "$DR">/dev/null; PR=~-/;}
for fn in $fn ;{
unset	Horz L CIR ELP l a xr yr modP modC mod modW modpt pin pres pfixes modr
mapfile -t l<"$fn"
for((i=2;i<${#l[@]};i++)){
	if [[ ${l[i]} =~ ^((LINE|CIRCLE|ARC|RECTANGLE) Normal )(.+)$'\r'$ ]] ;then #<- newline is \r\n, \n was stripped by mapfile
		mod=("${mod[@]}" $i "${BASH_REMATCH[1]}" "${BASH_REMATCH[3]}")
		a=$a\ ${BASH_REMATCH[3]}
	elif [[ ${l[i]} =~ ^PIN( [-0-9]+ [-0-9]+)(.+)$'\r'$ ]] ;then
		modP=("${modP[@]}" $i PIN "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")
	elif [[ ${l[i]} =~ ^(WINDOW [0-9]+ )([-0-9]+ [-0-9]+)(.+)$'\r'$ ]] ;then
		modW=("${modW[@]}" $i "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}");fi
}
a=($a);for((i=0;i<${#a[@]};i+=2)){
	xr=(${xr[@]} ${a[i]});	yr=(${yr[@]} ${a[i+1]})
}
IFS=$'\n' x=(`sort -n<<<"${xr[*]}"`);y=(`sort -n<<<"${yr[*]}"`)
if((x[-1]-x[0]-y[-1]+y[0]>0))	;then	Horz=1
	((DG=((t=x[-1]+x[0]>0))? D: ((D-((L=180))))))
	((D%90)) && DG=$DG\ -$((t? D: ((D+180))))
else
	L=-90;((a=D+90))
	((DG=((t=y[-1]+y[0]>0))? a: ((D-((L=90))))))
	((D%90)) && DG=$DG\ $((t? ((-D+90)): -a))
fi
let dx=(x[0]+x[-1])/2;let dy=(y[0]+y[-1])/2
unset IFS
for d in $DG ;{
	((K=L+d))
	d=`bc -l<<<"$d/180*3.1415926535897932384626434"`
	cos=`bc -l<<<"c($d)"`;	sin=`bc -l<<<"s($d)"`;	minsin=`bc -l<<<"-1*$sin"`
	rotM=($cos $minsin $sin $cos)
	for((i=0;i<${#modP[@]};i+=4)){
		p=(${modP[i+2]})
		pd=($((p[0]-dx)) $((p[1]-dy)))
		for((c=0;c<2;c++)){	M=0
			for((cr=0;cr<2;cr++)){	M=`bc<<<"$M+${pd[cr]}*${rotM[cr*2+c]}"`;}
			printf -v M %.0f $M; pin[c]=$M
			((pinfix[c]=((M+${M%%[0-9]*}15)/16)*16))
		}
		pres=(${pres[@]} ${pin[@]})
		pfixes=(${pfixes[@]} ${pinfix[@]})
		l[modP[i]]=PIN\ ${pinfix[@]}${modP[i+3]}$'\r'
	}
	for((i=0;i<${#mod[@]};i+=3)){
		pts=(${mod[i+2]});	unset md
		for((j=0;j<${#pts[@]};j+=2)){
			md=("${md[@]}" $((pts[j]-dx)) $((pts[j+1]-dy)));	}
		[[ "${mod[i+1]}" == CI* ]] &&{
			((a=${md[0]}-${md[2]}));((b=${md[1]}-${md[3]}))
			a=${a#-};((ELP=(a-${b#-})));((CIR=!ELP))
		}
		((ELP)) || [[ "${mod[i+1]}" == AR* ]] &&{	echo skipping $fn as it has ellipse/arc draw part;continue 2;}
		for((r=0;r<$((${#pts[@]}));r+=2)){
			for((c=0;c<2;c++)){	M=0
				for((cr=0;cr<2;cr++)){
					M=`bc<<<"$M+${md[r+cr]}*${rotM[cr*2+c]}"`;}
				printf -v modpt[c] %.0f $M
				modr[r+c]=${modpt[c]}
			}
			for((k=0;k<${#pres[@]};k+=2)){
				[[ "${modpt[@]}" == "${pres[k]} ${pres[k+1]}" ]] &&{	((modr[r]=pfixes[k]));((modr[r+1]=pfixes[k+1]));}
			}
		}
		((CIR))&&{	((a/=2));CIR=
			((cx=(modr[0]+modr[2])/2));((cy=(modr[1]+modr[3])/2))
			modr=( $((cx-a)) $((cy-a)) $((cx+a)) $((cy+a)) )
		}
		l[mod[i]]=${mod[i+1]}${modr[@]}$'\r'
	}
	for((i=0;i<${#modW[@]};i+=4)){
		pd=(${modW[i+2]})
		pd=($((pd[0]-dx)) $((pd[1]-dy)))
		SD=${modW[i+3]}
		if [[ "${modW[i+1]}" = *0\  ]];then	((pd[1]-=5))
			if(((K==45))) ;then
				((pd[0]=pfixes[0]>pfixes[2]?pfixes[0]-8:pfixes[2]-8))
				SD=Right${SD/Left}
			else		((pd[0]=pfixes[0]<pfixes[2]?pfixes[0]+11:pfixes[2]+11))	;fi
		elif [[ "${modW[i+1]}" = *162\  ]] ;then
			p=(${pd[@]})
			for((c=0;c<2;c++)){	M=0
				for((cr=0;cr<2;cr++)){	M=`bc<<<"$M+${p[cr]}*${rotM[cr*2+c]}"`;}
				printf -v pd[c] %.0f $M
			}
		else	((pd[1]+=7))
			if((K==45)) ;then ((pd[0]-=31))
			else
				((pd[0]=pfixes[0]<pfixes[2]?pfixes[0]:pfixes[2]));fi
		fi
		l[modW[i]]=${modW[i+1]}${pd[@]}$SD$' \r'
	}
	fn=${fn##*/};tn=${fn%.asy}$K.asy;echo -n creating $tn...
	for((i=0;i<${#l[@]};i++)){	echo ${l[i]};} >$PR$tn &&echo \ ok
};}
((F))||cd -;F=
};}
