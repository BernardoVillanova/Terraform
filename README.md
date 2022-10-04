## HOW-TO

### For the initial run of each folder, start with:

#### `terraform init`

##### Run so that terraform starts in that folder

#### `terraform plan` or `terraform plan -out somethingfile.txt`

##### Executed to compile what will be executed/created by terraform

#### `terraform apply` or `terraform apply "somethingfile.txt"`

##### Finally, create the contents of the folder in AWS

### OBS:
##### Some variables can only be declared after creating everything, so on first boot use enter and then declare the requested variables on second boot
#### RDS user and pwd are saved in /1-vpc/vpc.tf