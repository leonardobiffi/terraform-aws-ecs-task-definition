output "arn" {
  value       = module.task_definition.arn
  description = "The ARN of the Task Definition"
}

output "family" {
  value = module.task_definition.family
}
