rotLTSym(){
D=${1%/};local F PR
#: ${D:=~/Documents/LTspiceXVII/lib/sym}
if [ -d "$D" ] ;then pushd $D;n=\*;F=1;PR=~-/
else	n=${D%.asy};: ${n:=\*};fi
for fn in $n.asy ;{
unset	CIR ELP PR l a x y modP modC mod modW modpt pin pres pfixes modr
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
a=($a);for((i=0;i<${#a[@]};i+=2)){	x=(${x[@]} ${a[i]});	y=(${y[@]} ${a[i+1]})
}
IFS=$'\n' xs=(`sort -n<<<"${x[*]}"`);ys=(`sort -n<<<"${y[*]}"`)
if((xs[-1]-xs[0]-ys[-1]+ys[0]<0));then Horz=;D=135\ 45
else Horz=1;D=45\ -45 ;fi
let dx=(xs[0]+xs[-1])/2;let dy=(ys[0]+ys[-1])/2
unset IFS
for D in $D ;{
	d=`bc -l<<<"$D/180*3.1415926535897932384626434"`
	cos=`bc -l<<<"c($d)"`
	sin=`bc -l<<<"s($d)"`
	minsin=`bc -l<<<"-1*$sin"`
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
		((ELP)) || [[ "${mod[i+1]}" == AR* ]] &&{	echo skipping $fn;continue 2;}
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
		if [[ "${modW[i+1]}" = *0\  ]] ;then	((pd[1]-=5))
			if((Horz))&&((D==-45))||(((!Horz))&&((D==45))) ;then
				((pd[0]=pres[0]<pres[2]?pres[0]+5:pres[2]+5))
			else
				((pd[0]=pres[0]>pres[2]?pres[0]-3:pres[2]-3))
				SD=Right${SD/Left};	fi
		elif [[ "${modW[i+1]}" = *162\  ]] ;then
			p=(${pd[@]})
			for((c=0;c<2;c++)){	M=0
				for((cr=0;cr<2;cr++)){	M=`bc<<<"$M+${p[cr]}*${rotM[cr*2+c]}"`;}
				printf -v pd[c] %.0f $M
			}
		else	((pd[1]+=3));fi
		l[modW[i]]=${modW[i+1]}${pd[@]}$SD$' \r'
	}
	((Horz))||((D-=90)); fn=${fn##*/}
	for((i=0;i<${#l[@]};i++)){	echo ${l[i]} ;}>$PR${fn%.asy}$D.asy
};};((F))&&popd
}
