variable "bucket_name" {
  type = string
}

variable "force_destroy" {
  type        = bool
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error"
  default     = false
}

variable "tags" {
  type = map(string)
  default = {
    name = "data-bucket"
  }
}
