exit=0

#Will open and/or create the directory containing the repositories being worked with.
if test -d ~/CVS; then
	cd ~/CVS
else
	mkdir ~/CVS
	cd ~/CVS
fi

#Command to open a repo.
openrepo()
{
	selectrepo=0
		while [[ selectrepo -ne 1 ]]; do
			#Citation: www.cyberciti.biz/faq/linux-unix-shell-check-if-directory-empty/
			if [[ "$(ls -A)" ]]; then
				ls
				repo=null
				echo "Type the name of the Repository to open."
				read repo
				if test -d repo; then
					cd repo
					ls
					selectrepo=1
				else
					echo "Repository not found. Try again."
				fi
			else
				echo "No repos found."
				echo ""
				selectrepo=1
			fi
		done
}

echo "Welcome to myCVS software, a CVS solution."

#Main program loop.
while [[ exit -ne 1 ]]; do
	echo "Please select a task with relevant number." 
	echo "1) Open Repository."
	echo "2) Create Repository."
	echo "3) Delete Repository."
	echo "4) Archive Repository."
	echo "0) Exit Program."

	#Handles user input.
	option=999
	read option
	if [[ option -eq 0 ]]; then
		exit=1
	elif [[ option -eq 1 ]]; then
		openrepo
	#elif [[ option -eq 2 ]]; then
		#statements
	#elif [[ option -eq 3 ]]; then
		#statements
	#elif [[ option -eq 4 ]]; then
		#statements
	elif [[ option -ne 12345 ]]; then
		echo "Invalid value. Try again."
		echo ""
	fi
done
