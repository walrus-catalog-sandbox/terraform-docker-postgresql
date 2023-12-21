output "message" {
  value       = format("Echo: %s", local.message)
  description = "Echo the input message."
}
