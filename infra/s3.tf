terraform {
  backend "s3" {
    # MUDE O NOME DO BUCKET para o que você criou, buckets devem ser unicos
    bucket = "my-tf-test-caq10151" 
    
    # O nome do farquivo pra colocar no bucker
    key    = "cs-t1-springboot/terraform.tfstate" 
    region = "us-east-1" 
  }
}