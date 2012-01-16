# $Id: v,v 1.10 2011/06/28 12:16:19 phil Exp $
function v {
	usage () {
		echo "usage: s=file v [-dhnV] [-l lines]" 1>&2
		echo "              v [-dhnV] [-l lines] file ..." 1>&2
	}

	myprint () {
		typeset len=$(wc -l "$1" | awk '{print $1}')
		if [ "$len" -gt "$max" ]
		then
			if [ $linenr -eq 1 ]
			then
				if [ $qp -eq 1 ]
				then
					qpc -d "$1" | less -N
				else
					less -N "$1"
				fi
			else
				if [ $qp -eq 1 ]
				then
					qpc -d "$1" | less
				else
					less "$1"
				fi
			fi
		else
			if [ $linenr -eq 1 ]
			then
				if [ $qp -eq 1 ]
				then
					qpc -d "$1" | cat -n
				else
					cat -n "$1"
				fi
			else
				if [ $qp -eq 1 ]
				then
					qpc -d "$1" | cat
				else
					cat "$1"
				fi
			fi
		fi
	}

	typeset max=$(($LINES * 3 / 4))
	typeset linenr=0
	typeset qp=0
	typeset id='$Id: v,v 1.10 2011/06/28 12:16:19 phil Exp $'

	# I'm doing this by hand and not with getopt(1)
	# because file arguments could be filenames with spaces.
	# With getopt(1) these filenames will not survive intact
	# after the getopt(1) call.
	while [[ $# > 0 && "$1" = \-* ]]
	do
		typeset op=$1
		op=`echo "X$op" | sed -e 's/^X-//'`
		if [[ "$op" != +([hndVl0-9]) ]]
		then
			usage
			unset -f usage myprint
			return 1
		fi
		while [[ "$op" = +([hndVl0-9]) ]]
		do
			if [[ "$op" = h* ]]
			then
				echo "Prints files with cat or less depending" 1>&2
				echo "on the number of lines." 1>&2
				echo "Default: use cat if #lines <= 3/4 * \$LINES" 1>&2
				echo 1>&2
				echo "Several files can be given as the last" 1>&2
				echo "commandline arguments or one file can be" 1>&2
				echo "specified in the variable s." 1>&2
				echo "Only one of both variants is used." 1>&2
				echo "Commandline arguments take precedence over \$s." 1>&2
				echo "For example, both commands print the same file:" 1>&2
				echo "  $ v ~/notes/openbsd" 1>&2
				echo "  $ s=~/notes/openbsd v" 1>&2
				echo 1>&2

				usage

				echo 1>&2
				echo "options:" 1>&2
				echo "      -h          print this help" 1>&2
				echo "      -d          decode quoted-printables" 1>&2
				echo "      -l #lines   number of lines when to use less" 1>&2
				echo "      -n          print line numbers" 1>&2
				echo "      -V          prints version and exits" 1>&2

				unset -f usage myprint
				return 0
			elif [[ "$op" = n* ]]
			then
				linenr=1
				op=`echo "$op" | sed -e 's/^n//'`
			elif [[ "$op" = d* ]]
			then
				qp=1
				op=`echo "$op" | sed -e 's/^d//'`
			elif [[ "$op" = l* ]]
			then
				typeset ltmp
				if [[ "$op" = "l" ]]
				then
					shift
					ltmp="$1"
					op=`echo "$op" | sed -e 's/^l//'`
				else
					ltmp=$(echo "$op" | sed -E 's/^l[[:space:]]*//')
					op=$(echo "$op" | sed -E 's/^l[[:space:]]*[[:digit:]]*//')
				fi
				if [[ "$ltmp" != +([0-9]) ]]
				then
					usage
					unset -f usage myprint
					return 1
				fi
				max="$ltmp"
			elif [[ "$op" = V* ]]
			then
				echo "$id" | sed -e 's/^.Id://' -e 's/\$$//'
				unset -f usage myprint
				return 0
			else
				usage
				unset -f usage myprint
				return 1
			fi
		done
		shift
	done

	if [ $# -gt 0 ]
	then
		i=0
		while [ $# -gt 0 ]
		do
			if [ -r "$1" ]
			then
				myprint "$1"
			else
				echo "v: $1: No such file or directory" 1>&2
			fi
			shift
		done
	elif [ "$s" ]
	then
		if [ -r "$s" ]
		then
			myprint "$s"
		else
			echo "v: $s: No such file or directory" 1>&2
		fi
	else
		usage
		unset -f usage myprint
		return 1
	fi

	unset -f usage myprint
}
