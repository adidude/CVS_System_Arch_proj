
#This function archives the project in three different formats.
Archive()
{
	read -p "\nplease enter the file location you want to Archive (e.g. /home/user/file1): " SFOLDER1
	read -p "Please enter the location to save this zip file (e.g. /home/user/repository):" DFOLDER1
	read -p "Select archive type (zip or tar.gz,):" COMPRES1
	case $COMPRES1 in
		zip) zip -erj ${DFOLDER1}/file1.zip $SFOLDER1;; # for zip 
		tar.gz) tar cvfz ${DFOLDER1}/file1.tar.gz $SFOLDER1;; # for tar.gz
		

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
	echo "Enter the full path of repository you want to see (e.g. /home/user/repository):"
	read repo_path
	for entry in "$repo_path"/*
	do
		echo "$entry"
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

	echo "              New changes             ">> log.txt
	echo "--------------------------------------">> log.txt

 # logs the username ,date and time
 echo "$(whoami)" >> log.txt  
 echo "$(date)" "$input " >> log.txt 
 #Asks for comments about changes made and log them on file.
 echo " please enter any comments you have about these changes"
 read comments
 echo " $comments" >> log.txt

#compares two files side by side and log them on file.
diff -ry  $org_file $new_file >> log.txt

#grep -n -v -f $org_file $new_file >> log.txt

echo " changes logged to log.txt file sucessfully!"
}



# Menu 
while true
do
	
	
	echo "---------Main Menu---------"
	echo "1) Archive Project"
	echo "2) Edit file"
	echo "3) ListFiles"
	echo "4) Difference"
	echo "e) Exit"
	echo "Please select one of the options"

	read choice # Reads user's choice

	case "$choice" in
		
1) Archive;;
2) EditFile;;
3) ListFiles;;
4) Difference;;

e) exit;;
esac
done


