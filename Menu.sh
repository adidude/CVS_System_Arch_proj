exit=0

#Will open and/or create the directory containing the repositories being worked with.
if test -d ~/CVS; then
	cd ~/CVS
else
	mkdir ~/CVS
	cd ~/CVS
fi

#Command to open a repo.
openDir()
{
	#Loops as long as a directory has not been selected or if there are no directories to open.
	selectDir=0
		while [[ selectDir -ne 1 ]]; do
			#Citation: www.cyberciti.biz/faq/linux-unix-shell-check-if-directory-empty/
			#If folder is not empty get user input and test if the directory exists.
			if [[ "$(ls -A)" ]]; then
				echo "File list:"
				ls -d *
				dir=null
				echo "Type the name of the directory to open."
				read dir
				if test -d $dir; then
					#Open directory and display contents as well as current directory location.
					cd $dir
					pwd
					ls
					selectDir=1
					projectMenu
				else
					echo "directory not found. Try again."
				fi
			else
				echo "No directory found."
				echo ""
				selectDir=1
			fi
		done
}

#Will create a repo.
createDir()
{
	createdDir=0
	#Will loop as long as directory has not been created.
	while [[ createdDir -eq 0 ]]; do
		echo "Type the name of the new repository:"
		reponame=null
		read reponame
		if [[ -d $reponame ]]; then
			echo "Repository with that name already exists."
			echo ""
		else
			mkdir $reponame
			createdDir=1
			echo ""
		fi
	done		
}

#Deletes a repo.
deleteRepo()
{
	deleterepo=0
	#As long as the repo is not deleted loop continues.
	while [[ deleterepo -eq 0 ]]; do
		#Tests if there are any directories to delete.
		if [[ "$(ls -A)" ]]; then
			echo "File list:"
			ls
			repo=null
			echo "Type the name of the Repository to delete."
			read repo
			#Tests if repo exists.
			if test -d $repo; then
				rm -Rf $repo
				deleterepo=1
				echo "Successfully deleted repository."
				echo ""
			else
				echo "Repository not found. Try again." 
			fi
		else
			echo "No repos found to delete."
			echo ""
			deleterepo=1
		fi
	done	
		
}

#Will commit files
#commit()
#{

#}

openFile()
{
	echo "File list:"
	ls -sort *.*
	echo "Type the file you want to open"
	read file
	subl $file
}

#Menu for once a project has been opened.
projectMenu()
{
	exitMenu=0
	while [[ exitMenu -eq 0 ]]; do
		echo "Please select a task with relevant number." 
		echo "1) Open text file"
		echo "2) Commit file"
		echo "3) Commit all changes"
		echo "4) Open directory"
		echo "0) Exit repository"

		#Handles user input.
		option=999
		read option
		if [[ option -eq 0 ]]; then
			exitMenu=1
		#elif [[ option -eq 1 ]]; then
			
		#elif [[ option -eq 2 ]]; then
			
		#elif [[ option -eq 3 ]]; then
			
		elif [[ option -eq 4 ]]; then
			openDir
		else
			echo "Invalid value. Try again."
			echo ""
		fi
	done
	cd ..
}

echo "Welcome to myCVS software, a CVS solution."

#Main program loop.
while [[ exit -ne 1 ]]; do
	echo "Please select a task with relevant number." 
	echo "1) Open Repository"
	echo "2) Create Repository"
	echo "3) Delete Repository"
	echo "4) Archive Repository"
	echo "5) Clone Repository"
	echo "0) Exit Program"

	#Handles user input.
	option=999
	read option
	if [[ option -eq 0 ]]; then
		exit=1
	elif [[ option -eq 1 ]]; then
		openDir
	elif [[ option -eq 2 ]]; then
		createDir
	elif [[ option -eq 3 ]]; then
		deleteRepo
	#elif [[ option -eq 4 ]]; then
		#statements
	else
		echo "Invalid value. Try again."
		echo ""
	fi
done