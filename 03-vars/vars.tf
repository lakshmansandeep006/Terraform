variable "a" {
  default = "10"
}

output "op" {
  value = var.a
}

# list variables

variable "sample" {
  default = [
    100,
    "terraform",
  true]
}

# printing while list variable

output "sample_op_works" {
  value = "current topic is ${var.sample[1]} and this supports more than ${var.sample[0]} cloud providers"
}


# var.sample   : use this only if this is not in between a set of strings
# {var.sample} : use this if our variable has  to be enclosed in a set of strings
#________________________________________________________________________________________

# Map Variable

variable "m" {
  default = {
    name    = "Mike"
    content = "DevOps"
    salary  = "10000"
  }
}



output "op_m" {
  value = "${var.m["name"]} is a ${var.m["content"]} and his salary is ${var.m["salary"]}"

}