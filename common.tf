locals {
    common_tags = {
        service_initial_name = "${var.environment_name}-${var.service_base_name}"
    }
}
