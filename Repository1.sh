#Authors: Aditya Kumar Menon,	Mandar Tamhane,		Rauf Nawaz Tarar
#MatricNo.: 170025886			170021792			170012145

#This function archives the project in three different formats.
Archive()
{
	ls ~/CVS/
	read -p "\nplease enter the repository you want to Archive: " SFOLDER1
	read -p "Please enter the location to save this zip file (e.g. /home/user/repository):" DFOLDER1
	read -p "Select archive type (zip or tar.gz,):" COMPRES1
	case $COMPRES1 in
		zip) zip -erj ${DFOLDER1}/$(SFOLDER1).zip ~/CVS/$SFOLDER1;; # for zip 
		tar.gz) tar cvfz ${DFOLDER1}/$(SFOLDER1).tar.gz ~/CVS/$SFOLDER1;; # for tar.gz
		

 # Error handling for entering wrong type, shows an error message
 *) echo "Please enter a valid compression type (zip or tar.gz)";
exit;;

#end of case statment
esac 
}


#This funtion edits the file and creates backup before editing
EditFile()
{
	ListFiles #Calls for list function for showing whats in the directory
	echo "Enter the file name you want to edit (e.g. file1):"
	read fileName
	cp $fileName "$fileName"_Backup # Creates a backup file
	nano $fileName # opens the file in nano editor for editing in terminal.
}

#This function lists all the files in directory
ListFiles()
{
	echo "Enter the name of repository you want to see:"
	ls ~/CVS
	listed=0
	while [[ listed -eq 0 ]]; do
		read repo_path
		if [[ -d ~/CVS/$(repo_path) ]]; then
			for entry in ~/CVS/$(repo_path)/*
			do
				echo "$entry"
			done
		fi
	done
}



#This funtion look for changes in file and log all the changes to new file with date, username and additional comments.
Difference()
{
	echo "========================"
	echo "please enter original file path (e.g. /home/user/file1):"
	read org_file
	echo "please enter new file path (e.g. /home/user/file2):"
	read new_file

	echo "              Changes             " > diff
	echo "--------------------------------------" > diff

	#compares two files side by side and log them on file.
	diff $org_file $new_file > diff

	echo "Differences can be viewed in diff file."
}