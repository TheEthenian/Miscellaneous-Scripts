find . -name "*(_PDFDrive_)*" -type f | rename 's/(_PDFDrive_)/ /g'
find . -name "*(*" -type f | rename 's/(/ /g'
find . -name "*(*" -type f | rename 's/(/ /g'
find . -name "* *" -type f | rename 's/ /_/g'








