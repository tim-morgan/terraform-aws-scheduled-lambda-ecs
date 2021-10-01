###########################################################
#  backend/providers                                      #
###########################################################



provider "aws" {
    region = "us-east-2"
    # allowed_account_ids = [""]  
}

terraform {
    required_version = "~> 1.0.0"
    required_providers {
      aws = {
          version = "~> 3.59"
      }
    }

    # local backend 

}