# wpwithterraform
#Minimum requirement
1. You must have terraform already installed your workstation.
2. AWS account with Access key and secret key
3. Pem key name assocaited with your AWS account. To generate key pair refer : http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

#To build the infrastructure follow the below patter
./buildinfra.sh  minimumno.ofserver accesskey secretkey envname instancetype keyname
	Eg: ./buildinfra.sh  2 ATRFVNKIUHQ OIUOIU7lkjkhjouc uat t2.micro stealth


#To destroy an existing infra creted with above pattern execute command as follows

./destroyinfra.sh  minimumno.ofserver accesskey secretkey envname instancetype keyname
        Eg: ./destroyinfra.sh  2 ATRFVNKIUHQ OIUOIU7lkjkhjouc uat t2.micro stealth



#POINT To REMEMBER
Do not remove your tfstate files .
